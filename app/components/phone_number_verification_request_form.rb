# typed: true
# frozen_string_literal: true

class Components::PhoneNumberVerificationRequestForm < Components::Base
  # == Initialization ==

  sig do
    params(
      verification_request: PhoneNumberVerificationRequest,
      options: T.untyped,
    ).void
  end
  def initialize(verification_request:, **options)
    @verification_request = verification_request
    @options = options
    super()
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      model: if @verification_request.persisted?
               [ :verify, @verification_request ]
             else
               @verification_request
             end,
      method: :post,
      class: "flex flex-col gap-2",
      **@options,
    ) do |form|
      field_for(form, :phone_number) do |f|
        f.phone_number_input(
          placeholder: "your phone #",
          disabled: @verification_request.persisted?,
        )
        f.error
      end

      if @verification_request.persisted?
        field_for(form, :verification_code) do |f|
          f.text_input(
            placeholder: "verification code",
            inputmode: "numeric",
            autocomplete: "one-time-code",
            value: Rails.env.development? ? @verification_request.verification_code : nil,
          )
          f.error
        end
      end

      submit_button_for(form) do |button|
        if @verification_request.new_record?
          button.inline_start_icon("huge/sms-code")
          span { "send verification code" }
        else
          span { "complete login" }
          button.inline_end_icon("huge/arrow-right-02")
        end
      end
    end
  end
end
