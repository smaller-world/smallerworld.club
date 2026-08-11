# typed: strict
# frozen_string_literal: true

class Views::Admin::Reports::Index < Views::Base
  include Phlex::Rails::Helpers::Pluralize

  # == Initialization ==

  sig { params(reports: T::Enumerable[Report], pagy: Pagy::Offset).void }
  def initialize(reports:, pagy:)
    super()
    @reports = reports
    @pagy = pagy
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: [ "admin", "reports" ]) do |app_layout|
      main do
        app_layout.page_container(class: "max-w-lg flex flex-col gap-6") do
          unless hotwire_native_app?
            div(class: "flex gap-2 justify-between items-center") do
              button_back_to(
                "admin dashboard",
                [ :admin, :dashboard ],
                variant: :secondary,
              )
              span(class: "text-sm text-muted-foreground") do
                pluralize(@pagy.count, "report")
              end
            end
          end

          Components::ItemGroup(class: "empty:hidden gap-3") do
            @reports.each do |report|
              report_item(report)
            end
          end

          Components::Empty(
            class: "hidden [[role=list]:empty+&]:revert-display-layer",
          ) do |empty|
            empty.header(class: "gap-0") do
              empty.media(variant: :icon) do
                Icon("huge/flag-01")
              end
              empty.title do
                "no reports yet!"
              end
            end
          end

          if @pagy.last > 1
            div(class: "flex justify-center") do
              # Pagy builds this markup itself; no user input reaches it.
              raw(safe(@pagy.series_nav)) # rubocop:disable Rails/OutputSafety
            end
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(report: Report).void }
  def report_item(report)
    reportable = report.reportable!
    Components::Item(
      element: :a,
      variant: report.resolved? ? :muted : :outline,
      href: admin_report_path(report),
      class: "flex-nowrap items-start gap-2",
    ) do |item|
      item.content do |item_content|
        div(class: "flex gap-2 items-center") do
          reportable_icon(reportable, class: "size-4")
          item_content.title(class: "font-mono text-xs") do
            plain(reportable_label(reportable))
            whitespace
            plain(reportable.id)
          end
        end
        div(class: "flex flex-col *:flex *:items-center *:gap-2 **:[svg]:text-muted-foreground **:[svg]:size-4") do
          div do
            Icon("huge/flag-01")
            item_content.description { report.category.text }
          end
          div do
            Icon("huge/calendar-04")
            item_content.description do
              reportable_label(reportable)
              whitespace
              plain(
                "reported by #{report.reporter!.name} on #{report.created_at.to_fs(:short)}",
              )
            end
          end
        end
      end
      item.actions do
        Components::Badge(variant: status_badge_variant(report)) do
          report.resolution&.text || "pending"
        end
      end
    end
  end

  sig { params(report: Report).returns(Symbol) }
  def status_badge_variant(report)
    case report.resolution
    when "upheld" then :destructive
    when "dismissed" then :outline
    else :default
    end
  end

  sig { params(reportable: T.all(ActiveRecord::Base, Reportable)).returns(String) }
  def reportable_label(reportable)
    reportable.model_name.human
  end

  sig do
    params(
      reportable: T.all(ActiveRecord::Base, Reportable),
      options: T.untyped,
    ).void
  end
  def reportable_icon(reportable, **options)
    icon = case reportable
    when User
      "huge/user"
    when Post
      "huge/content-writing"
    else
      raise "Unsupported reportable type: #{reportable.class}"
    end
    Icon(icon, **options)
  end
end
