# typed: strict
# frozen_string_literal: true

class Components::WorldV1PostsImportAlert < Components::Base
  include Phlex::Rails::Helpers::Pluralize

  # == Initialization ==

  sig do
    params(
      world: World,
      import_job: T.nilable(SolidQueue::Job),
      attributes: T.untyped,
    ).void
  end
  def initialize(world:, import_job:, **attributes)
    super(**attributes)
    @world = world
    @import_job = import_job
  end

  # == Component ==

  sig { override.void }
  def view_template
    if has_importable_posts? || @import_job
      div(class: "flex flex-col gap-1.5") do
        Components::Alert(**compact_mix(
          {
            class: current_import_finished? ? "pr-30" : "pr-28",
            data: {
              variant!: (:destructive if @import_job&.failed?),
              action: token_list(
                "user-focus:active@document->frame-reload#reload" => @import_job.present?,
              ),
            },
          },
          reset_frame_after_import_attributes,
          @attributes,
        )) do |alert|
          alert.title do
            if @import_job
              if @import_job.finished?
                "import complete!"
              else
                "importing posts..."
              end
            else
              "import posts from v1?"
            end
          end
          alert.description do
            if (import_job = @import_job)
              import_progress_text(import_job:)
            else
              "you have " \
                "#{pluralize(@world.unimported_v1_posts.count, "unimported post")} on " \
                "smaller world v1."
            end
          end
          alert.action do
            form_with(url: [ @world, :v1_posts_import ], method: :post) do |form|
              submit_button_for(
                form,
                size: :sm,
                disabled: !!@import_job,
                class: class_names("loading *:invisible" => @import_job&.claimed?),
              ) do |button|
                if @import_job&.finished?
                  button.inline_start_icon("huge/checkmark-circle-01")
                  span { "imported" }
                elsif @import_job&.failed?
                  button.inline_start_icon("huge/alert-01")
                  span { "failed" }
                else
                  button.inline_start_icon("huge/delivery-truck-01")
                  span { "import" }
                end
              end
            end
          end
        end
        div(class: "flex items-center justify-center") do
          Components::Badge(variant: :ghost) { "beta" }
          span(class: "text-xs text-muted-foreground text-center") do
            "imports #{Rails.configuration.v1_posts_import_limit} posts at a time"
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def has_importable_posts?
    @has_importable_posts ||= T.let(
      @world.has_importable_v1_posts?,
      T.nilable(T::Boolean),
    )
  end

  sig { returns(T::Boolean) }
  def currently_importing?
    @import_job.present?
  end

  sig { returns(T.untyped) }
  def current_import_finished?
    T.let(
      if (import_job = @import_job)
        import_job.finished?
      else
        false
      end,
      T::Boolean,
    )
  end

  sig { params(import_job: SolidQueue::Job).returns(String) }
  def import_progress_text(import_job:)
    if import_job.finished? || import_job.claimed?
      imported_count = import_job_imported_posts_count(import_job)
      total_count = import_job_total_posts_count(import_job)
      "imported #{imported_count} of #{total_count} posts"
    elsif (failed_execution = import_job.failed_execution)
      if (error = failed_execution.error) &&
          error.is_a?(Hash) &&
          (message = error.fetch("message"))
        lines = message.lines
        message = "import failed with error: #{lines.first}"
        lines.many? ? message + "..." : message
      else
        "import failed :("
      end
    else
      "waiting for import to start..."
    end
  end

  sig { params(import_job: SolidQueue::Job).returns(Integer) }
  def import_job_imported_posts_count(import_job)
    scope = @world.posts.with_v1_attributes
    last_created_at = import_job_options(import_job).fetch(:last_imported_post_created_at)
    if last_created_at
      scope.where!("posts.created_at > ?", last_created_at)
    end
    scope.count
  end

  sig { params(import_job: SolidQueue::Job).returns(Integer) }
  def import_job_total_posts_count(import_job)
    # The posts imported by this job plus those still unimported is invariant
    # during the run (each post moves from one bucket to the other), so this
    # stays fixed at the count that was unimported when the job was enqueued.
    unbounded_total = import_job_imported_posts_count(import_job) +
      @world.unimported_v1_posts.count
    limit = import_job_options(import_job).fetch(:limit)
    if limit.is_a?(Integer)
      [ limit, unbounded_total ].min
    else
      unbounded_total
    end
  end

  sig { params(import_job: SolidQueue::Job).returns(T::Array[Integer]) }
  def import_job_progress(import_job)
    imported_count = import_job_imported_posts_count(import_job)
    total_count = import_job_total_posts_count(import_job)
    [ imported_count, total_count ]
  end

  sig { params(job: SolidQueue::Job).returns(T::Hash[Symbol, T.untyped]) }
  def import_job_options(job)
    _world_args, options = job.arguments.fetch("arguments")
    ActiveJob::Arguments.deserialize([ options ]).first
  end

  sig { returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def reset_frame_after_import_attributes
    if @import_job && (@import_job.finished? || @import_job.failed?)
      {
        data: {
          controller: "connection",
          connection_delay_value: 4000,
          action: "connection:connect->frame-reset#reset",
        },
      }
    end
  end
end
