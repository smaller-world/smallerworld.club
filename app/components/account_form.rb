# typed: strict
# frozen_string_literal: true

class Components::AccountForm < Components::Base
  include Phlex::Rails::Helpers::HiddenFieldTag

  # == Initialization ==

  sig { params(user: User, attributes: T.untyped).void }
  def initialize(user:, **attributes)
    super(**attributes)
    @user = user
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      model: @user,
      url: account_path,
      class: "flex flex-col gap-2",
      **@attributes,
    ) do |form|
      form.hidden_field(:time_zone_name, data: { controller: "current-time-zone-input" })

      field_for(form, :name) do |f|
        f.text_input(
          placeholder: "what's your name?",
          autocomplete: "given-name",
          maxlength: User::NAME_MAX_LENGTH,
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
