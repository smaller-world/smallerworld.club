# typed: true
# frozen_string_literal: true

class Components::PhoneNumberVerificationRequestForm < Components::Base
  include Phlex::Rails::Helpers::HiddenField

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
    model = if @verification_request.persisted?
      [ :verify, @verification_request ]
    else
      @verification_request
    end

    form_with(
      model:,
      method: :post,
      class: "flex flex-col gap-2 **:data-[slot=field]:gap-1",
      data: {
        turbo_action: "replace",
      },
      **@options,
    ) do |form|
      hidden_field(:user, :time_zone_name, data: { controller: "current-time-zone-input" })

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
            maxlength: 6,
            pattern: "[0-9]{6}",
            value: Rails.env.development? ? @verification_request.verification_code : nil,
          )
          if Rails.env.development?
            f.description(class: "text-xs text-center") do
              "code auto-filled for development"
            end
          end
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
