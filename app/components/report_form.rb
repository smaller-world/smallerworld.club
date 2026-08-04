# typed: strict
# frozen_string_literal: true

class Components::ReportForm < Components::Base
  # == Initialization ==

  sig do
    params(
      report: Report,
      attributes: T.untyped,
    ).void
  end
  def initialize(report:, **attributes)
    super(**attributes)
    @report = report
    @reportable = T.let(@report.reportable!, T.all(ActiveRecord::Base, Reportable))
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @report,
      action:,
      vibrate_on_submit: true,
      data: {
        turbo_temporary: true,
        controller: "report-form transition-group",
        report_form_reportable_label_value: reportable_label,
        action: "report-form:expand->transition-group#start",
      },
    ) do |form|
      form.wrapped(
        form.field(:category).select(
          Report.category.values,
          placeholder: "please select one",
          required: true,
          data: {
            report_form_target: "categoryInput",
            action: "change->report-form#updateNoteField",
          },
        ) do |select|
          select.with_content(class: "w-(--button-width)") do |select_content|
            select.default_item_group(select_content:)
          end
        end,
        label: "what's wrong with this #{reportable_label}?",
      )

      Components::Field(
        class: class_names("hidden" => !@report[:category]),
        data: {
          report_form_target: "noteField",
          transition_group_target: "item",
          controller: "transition",
          transition_enter_start: "opacity-0 -translate-y-1",
          transition_enter: "transition-[opacity,translate] duration-200 ease-in-quart",
          action: [
            "transition-group:start->transition#enter",
            "transition:entered->transition-group#startNext",
          ],
        },
      ) do |field|
        form.Field(:note).label do
          @report.note_required? ? "note" : "note (optional)"
        end
        field.description(class: "leading-snug")
        form.Field(:note).textarea(
          required: @report.note_required?,
          class: "min-h-24",
        )
      end

      form.submit(
        variant: :destructive,
        class: class_names("hidden" => !@report[:category]),
        data: {
          transition_group_target: "item",
          controller: "transition",
          transition_enter_start: "opacity-0",
          transition_enter: "transition-opacity duration-200 ease-in-quart",
          action: "transition-group:start->transition#enter",
        },
      ) do |button|
        button.inline_start_icon("huge/flag-01")
        span { "report #{reportable_label}" }
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(Object) }
  def action
    if @report.new_record?
      [ @reportable, :reports ]
    else
      @report
    end
  end

  sig { returns(String) }
  def reportable_label
    @reportable.model_name.human
  end
end
