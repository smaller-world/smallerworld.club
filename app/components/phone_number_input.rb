# typed: strict
# frozen_string_literal: true

class Components::PhoneNumberInput < Components::Input
  include Phlex::Rails::Helpers::HiddenFieldTag

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexRailsFormBuilder),
      field: T.nilable(Symbol),
      name: T.nilable(String),
      id: T.nilable(String),
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, name: nil, id: nil, **attributes)
    super(form:, field:, **attributes)
    @name = name
    @id = id
  end

  # == Component ==

  sig { override.void }
  def view_template
    div(
      class: "phone-number-input-container",
      data: {
        controller: "phone-number-input",
      },
    ) do
      Components::Input(form: @form, field: @field, name: nil, id: field_id, **mix(
        {
          data: {
            phone_number_input_target: "input",
            action: [
              "change->phone-number-input#updateHiddenInput",
              "countrychange->phone-number-input#updateHiddenInput",
            ],
          },
        },
        @attributes,
      ))

      hidden_input_options = {
        name: field_name,
        data: {
          phone_number_input_target: "hiddenInput",
        },
      }
      if @form
        @form.hidden_field(@field, id: nil, **hidden_input_options)
      else
        hidden_field_tag(@field, **hidden_input_options)
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(String)) }
  def field_name
    if @name
      @name
    elsif @form && @field
      @form.field_name(@field)
    elsif @field
      super(@field)
    end
  end

  sig { returns(T.nilable(String)) }
  def field_id
    if @id
      @id
    elsif @form && @field
      @form.field_id(@field)
    elsif @field
      super(@field)
    end
  end
end
