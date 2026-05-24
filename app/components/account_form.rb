# typed: true
# frozen_string_literal: true

class Components::AccountForm < Components::Base
  include Phlex::Rails::Helpers::HiddenFieldTag

  # == Initialization ==

  sig do
    params(
      user: User,
      options: T.untyped,
    ).void
  end
  def initialize(user:, **options)
    @user = user
    @options = options
    super()
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      model: @user,
      url: account_path,
      class: "flex flex-col gap-2",
      # data: {
      #   controller: "account-form",
      # },
      **@options,
    ) do |form|
      form.hidden_field(:time_zone_name, data: { controller: "current-time-zone-input" })

      field_for(form, :name) do |f|
        f.text_input(
          placeholder: "your name",
          autocomplete: "given-name",
          data: {
            # account_form_target: "nameInput",
            # action: "account-form#updateSubmitButtonLabel",
          },
        )
        f.error
      end

      submit_button_for(form) do |button|
        button.inline_start_icon("huge/earth")
        span { "create account" }
      end
    end
  end
end
