# typed: strict
# frozen_string_literal: true

class Components::PhoneNumberVerificationRequestForm < Components::Base
  include Phlex::Rails::Helpers::HiddenField

  # == Initialization ==

  sig do
    params(
      verification_request: PhoneNumberVerificationRequest,
      attributes: T.untyped,
    ).void
  end
  def initialize(verification_request:, **attributes)
    super(**attributes)
    @verification_request = verification_request
  end

  # == Component ==

  sig { override.void }
  def view_template
    model = if @verification_request.persisted?
      [ :verify, @verification_request ]
    else
      @verification_request
    end

    form_with(
      model:,
      method: :post,
      id: :login_form,
      **normalize_mix(
        {
          class: "flex flex-col gap-4 **:data-[slot=field]:gap-1",
          data: {
            controller: "haptic-bridge",
            turbo_action: "replace",
            action: ("turbo:submit-end->haptic-bridge#vibrate" if @verification_request.persisted?),
          },
        },
        @attributes,
      ),
    ) do |form|
      hidden_field(:user, :time_zone_name, data: { controller: "current-time-zone-input" })

      field_for(form, :phone_number) do |field|
        field.phone_number_input(
          placeholder: "your phone #",
          disabled: @verification_request.persisted?,
          required: true,
        )
        field.error
      end

      if @verification_request.new_record?
        div(class: "rounded-xl ring-1 ring-foreground/10 overflow-hidden h-[61px] bg-card") do
          turnstile_tag(class: "-m-[2px]", data: { size: "flexible" })
        end
      else
        field_for(form, :verification_code) do |field|
          field.text_input(
            placeholder: "verification code",
            inputmode: "numeric",
            autocomplete: "one-time-code",
            maxlength: 6,
            pattern: "[0-9]{6}",
            value: (@verification_request.verification_code if Rails.env.development?),
          )
          if Rails.env.development?
            field.description(class: "text-xs text-center") do
              "code auto-filled for development"
            end
          end
          field.error
        end
      end

      div(class: "flex flex-col gap-1") do
        submit_button_for(form, size: :lg) do |button|
          if @verification_request.new_record?
            button.inline_start_icon("huge/sms-code")
            span { "send verification code" }
          else
            span { "complete login" }
            button.inline_end_icon("huge/arrow-right-02")
          end
        end
        if @verification_request.persisted?
          button_link_to(
            "wrong phone number?",
            new_session_path,
            size: :xs,
            class: "text-muted-foreground",
          )
        end
      end
    end
  end
end
