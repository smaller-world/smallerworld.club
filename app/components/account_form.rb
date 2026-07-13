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
    Components::Form(@user, action: account_path, **@attributes) do |form|
      form.Field(:time_zone_name).hidden(data: { controller: "current-time-zone-input" })

      form.wrapped(
        form.field(:name).text(
          placeholder: @user.new_record? ? "what's your name?" : @user.name,
          autocomplete: "given-name",
          maxlength: User::NAME_MAX_LENGTH,
        ),
        label: @user.new_record? ? "let's create your account!" : "your name",
      )

      form.submit do |button|
        button.inline_start_icon(@user.new_record? ? "huge/user" : "huge/floppy-disk")
        span do
          @user.new_record? ? "create account" : "save changes"
        end
      end
    end
  end
end
