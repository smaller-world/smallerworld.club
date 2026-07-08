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
    Components::Form(
      @user,
      action: account_path,
      **@attributes,
    ) do |form|
      form.Field(:time_zone_name).hidden(data: { controller: "current-time-zone-input" })

      form.wrapped(
        form.field(:name).text(
          placeholder: "what's your name?",
          autocomplete: "given-name",
          maxlength: User::NAME_MAX_LENGTH,
        ),
        label: "let's create your account!",
      )

      form.submit do |button|
        button.inline_start_icon("huge/user")
        span { "create account" }
      end
    end
  end
end
