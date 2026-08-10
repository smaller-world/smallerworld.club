# typed: strict
# frozen_string_literal: true

class Views::Admin::Reports::Show < Views::Base
  include Phlex::Rails::Helpers::FormWith

  # == Initialization ==

  sig { params(current_user: User, report: Report).void }
  def initialize(current_user:, report:)
    super()
    @current_user = current_user
    @report = report
    @reportable = T.let(
      @report.reportable!,
      T.all(ActiveRecord::Base, Reportable),
    )
    @reporter = T.let(@report.reporter!, User)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "report") do |app_layout|
      app_layout.page_container(class: "max-w-lg space-y-6") do
        button_back_to("all reports", [ :admin, :reports ], variant: :secondary)

        Components::Item(variant: :muted, class: "gap-4") do |item|
          item.content(class: "flex flex-col gap-2") do |item_content|
            div(class: "flex flex-col gap-0.5") do
              item_content.title(class: "flex gap-2 w-auto") do
                span(class: "flex-1") do
                  @report.category.text
                end
                Components::Badge(variant: status_variant) { status_label }
              end
              item_content.description do
                plain("reported by #{@reporter.name} on ")
                local_time(@reporter.created_at)
              end
            end

            if (note = @report.note)
              blockquote(
                class: "border-l-2 pl-3 whitespace-pre-wrap",
              ) do
                note
              end
            end
          end
          item.footer(
            class: "flex flex-col items-stretch gap-0.5",
          ) do
            if @report.resolved? &&
                (moderator = @report.moderator) &&
                (resolution = @report.resolution) &&
                (resolved_at = @report.resolved_at)
              p(class: "text-sm text-muted-foreground") do
                "#{resolution.text} by #{moderator.name} on " \
                  "#{resolved_at.to_fs(:long)}. you can change this."
              end
            end
            resolve_form
          end
        end

        # Components::Card() do |card|
        #   card.header do
        #     card.title { @report.category.text }
        #     end
        #   end

        section(class: "flex flex-col gap-2") do
          h2(class: "text-lg") { "reported #{reportable_label}" }
          reported_content
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def status_label
    @report.resolution&.text || "pending resolution"
  end

  sig { returns(String) }
  def reportable_label
    @reportable.model_name.human
  end

  sig { returns(Symbol) }
  def status_variant
    case @report.resolution
    when "upheld" then :destructive
    when "dismissed" then :outline
    else :default
    end
  end

  # Renders the reported record plainly, without the interactive components
  # users see. An admin generally holds no key to the world in question, so
  # anything routed through `PostPolicy` would be denied.
  sig { void }
  def reported_content
    case @reportable
    when Post
      reported_post(@reportable)
    when User
      reported_user(@reportable)
    else
      raise "Unexpected reportable type: #{@reportable.class}"
    end
  end

  sig { params(post: Post).void }
  def reported_post(post)
    Components::PostCard(current_user: @current_user, post:)
  end

  sig { params(user: User).void }
  def reported_user(user)
    Components::Card() do |card|
      card.header do
        card.title { user.name }
        card.description do
          "joined #{user.created_at.to_fs(:long)}"
        end
      end
    end
  end

  sig { void }
  def resolve_form
    Components::Form(
      @report,
      action: resolve_admin_report_path(@report),
      method: :post,
      class: "flex-row items-start gap-2",
      vibrate_on_submit: true,
    ) do |form|
      div(class: "flex-1 flex flex-col gap-0.5") do
        form.submit(
          name: "report[resolution]",
          value: "upheld",
          variant: :destructive,
        ) do |button|
          button.inline_start_icon("huge/flag-01")
          span { "uphold" }
        end
        span(class: "text-center text-xs text-muted-foreground") do
          "content remains hidden"
        end
      end
      div(class: "flex-1 flex flex-col gap-0.5") do
        form.submit(
          name: "report[resolution]",
          value: "dismissed",
          variant: :outline,
        ) do |button|
          button.inline_start_icon("huge/undo")
          span { "dismiss" }
        end
        span(class: "text-center text-xs text-muted-foreground") do
          "content is restored"
        end
      end
    end
  end
end
