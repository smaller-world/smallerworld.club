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

      Components::FieldSet(class: "gap-4") do |field_set|
        field_set.legend(class: "mb-0 text-xs text-muted-foreground font-normal text-center") do
          "let's get you set up with an account!"
        end

        form.wrapped(
          form.field(:name).text(
            placeholder: @user[:name] || "bobby",
            autocomplete: "given-name",
            maxlength: User::NAME_MAX_LENGTH,
          ),
          label: "your name",
        )

        form.wrapped(
          form.field(:unconfirmed_email_address).email(
            placeholder: @user[:email] || "bobbysue@happytown.life",
            maxlength: User::NAME_MAX_LENGTH,
          ),
          label: "your email",
        )
      end

      div(class: "flex flex-col gap-2") do
        form.submit do |button|
          button.inline_start_icon(
            @user.new_record? ? "huge/user-account" : "huge/floppy-disk",
          )
          span do
            @user.new_record? ? "create account" : "save changes"
          end
        end
        if @user.new_record?
          p(class: "text-xs text-muted-foreground text-center text-balance") do
            plain("by creating an account, you agree to our ")
            link_to(policies_path, class: "underline", target: "_blank", rel: "noopener") do
              "terms and policies"
            end
            plain(".")
          end
        end
      end
    end
  end
end
