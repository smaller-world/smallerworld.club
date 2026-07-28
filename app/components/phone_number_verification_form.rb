# typed: strict
# frozen_string_literal: true

class Components::PhoneNumberVerificationForm < Components::Base
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
    action = if @verification_request.persisted?
      [ :verify, @verification_request ]
    else
      @verification_request
    end
    Components::Form(
      @verification_request,
      action:,
      method: :post,
      vibrate_on_submit: @verification_request.persisted?,
      id: "phone_number_verification_form",
      class: "gap-4",
      data: {
        controller: "phone-number-verification-form",
      },
      **@attributes,
    ) do |form|
      if @verification_request.persisted? && @verification_request.phone_number_owner
        form.namespace(:phone_number_owner) do |owner|
          owner.Field(:time_zone_name).hidden(
            value: nil,
            data: {
              controller: "current-time-zone-input",
            },
          )
        end
      end

      Components::FieldSet(class: "gap-3") do
        form.wrapped(
          form.field(:phone_number).phone_number(
            placeholder: "your phone #",
            disabled: @verification_request.persisted?,
            required: true,
          ),
          label: false,
        )
        if @verification_request.persisted?
          form.wrapped(
            form.field(:verification_code).text(
              placeholder: "verification code",
              inputmode: "numeric",
              autocomplete: "one-time-code",
              maxlength: 6,
              pattern: "[0-9]{6}",
              value: (@verification_request.verification_code if Rails.env.development?),
              data: {
                controller: "tooltip connection",
                tooltip_content_value: "code auto-filled in development",
                action: token_list("connection:connect->tooltip#show" => Rails.env.development?),
              },
            ),
            label: false,
          )
        end
      end

      div(class: "space-y-2") do
        if @verification_request.new_record?
          div(class: "rounded-xl ring-1 ring-foreground/10 overflow-hidden h-[61px] bg-card") do
            turnstile_tag(class: "-m-[2px]", data: {
              size: "flexible",
              action: "turnstile:success->phone-number-verification-form#enableSubmitButton",
            })
          end
        end

        div(class: "flex flex-col gap-1") do
          form.submit(
            disabled: @verification_request.new_record?,
            data: {
              phone_number_verification_form_target: "submitButton",
            },
          ) do |button|
            if @verification_request.new_record?
              button.inline_start_icon("huge/sms-code")
              span { "send verification code" }
            else
              span { "complete login" }
              button.inline_end_icon("huge/arrow-right-02")
            end
          end
          if @verification_request.new_record?
            div(class: "text-xs text-muted-foreground text-center text-balance") do
              plain("by continuing, you agree to receive a ")
              span(class: "text-foreground/75 whitespace-nowrap") { "one-time" }
              plain(" sms message from: ")
              span(class: "text-foreground/75") { application_phone_number }
              br
              plain("")
            end
          else
            button_link_to(
              "wrong phone number?",
              new_session_path,
              size: :xs,
              class: "self-center text-muted-foreground",
            )
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def application_phone_number
    @application_phone_number ||= T.let(
      begin
        phone_number = Smallerworld.application.telnyx_phone_number
        Phonelib.parse(phone_number).international(true)
      end,
      T.nilable(String),
    )
  end
end
