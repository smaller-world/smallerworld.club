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
        if @user.new_record?
          field_set.legend(
            class: "mb-0 text-xs text-muted-foreground font-normal text-center",
          ) do
            "let's get you set up with an account!"
          end
        end

        form.wrapped(
          form.field(:name).text(
            placeholder: @user[:name] || "bobby",
            autocomplete: "given-name",
            required: true,
            maxlength: User::NAME_MAX_LENGTH,
          ),
          label: "your name",
        )

        email_address_value = @user[:unconfirmed_email_address] || @user[:email_address]
        email_address_field = form.field(:unconfirmed_email_address)
        Components::Field() do |field|
          render email_address_field.label { "your email" }
          render email_address_field.email(
            value: email_address_value,
            placeholder: email_address_value || "bobbysue@happytown.life",
            required: true,
          )
          if @user.unconfirmed_email_address? &&
              (current_email_address = @user[:email_address])
            field.description(class: "mt-0 flex flex-col gap-1 text-xs leading-snug") do
              span do
                plain("was previously: ")
                span(class: "text-primary") { current_email_address }
              end
              if @user.unconfirmed_email_address?
                span do
                  plain(
                    "we sent you a confirmation email to verify your new email address! " \
                      "didn't get it? ",
                  )
                  link_to(
                    "click here to send another one.",
                    resend_account_email_address_confirmation_path,
                    class: "underline underline-offset-4 text-primary",
                    data: {
                      turbo_prefetch: false,
                    },
                  )
                end
              end
            end
          end
          if email_address_field.invalid?
            render email_address_field.error
          end
        end
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
            link_to(
              policies_path,
              target: "_blank",
              rel: "noopener",
              class: "underline underline-offset-4",
            ) do
              "terms and policies"
            end
            plain(".")
          end
        end
      end
    end
  end
end
