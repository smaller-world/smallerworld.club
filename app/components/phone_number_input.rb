# typed: strict
# frozen_string_literal: true

class Components::PhoneNumberInput < Components::Input
  include Phlex::Rails::Helpers::HiddenFieldTag

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      default_country_code: String,
      disabled: T::Boolean,
      required: T::Boolean,
      value: T.nilable(T.any(String, Phonelib::Phone)),
      attributes: T.untyped,
    ).void
  end
  def initialize(
    form: nil,
    field: nil,
    default_country_code: "CA",
    disabled: false,
    required: false,
    value: nil,
    **attributes
  )
    @default_country_code = default_country_code
    @disabled = disabled
    @required = required
    @value = value
    super(form:, field:, **attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    div(class: "flex gap-2", data: { controller: "phone-number-input" }) do
      Components::Combobox(
        input: {
          type: "tel",
          value: country_value(country),
          required: true,
          class: "field-sizing-content px-2",
          data: {
            phone_number_input_target: "countryCodeInput",
            action: [
              "keydown.enter->phone-number-input#normalizeCountryCode:capture",
              "change->phone-number-input#guessCountryCodeIfNeeded",
            ],
            country_code: country.alpha2,
          },
        },
        disabled: @disabled,
      ) do |combobox|
        combobox.with_inline_start_addon(
          data: {
            phone_number_input_target: "countryFlagAddon",
          },
        ) do
          country_flag(country)
        end
        combobox.with_content(
          anchor: [ :bottom, :start ],
          class: "phone-number-input-options",
        ) do |content|
          content.with_list do |list|
            ISO3166::Country.all.each do |country| # rubocop:disable Rails/FindEach
              value = country_value(country)
              list.item(
                value:,
                data: {
                  phone_number_input_target: "countryCodeOption",
                  country_code: country.alpha2,
                  action: "pointerdown->phone-number-input#setCountryCode",
                },
              ) do
                country_flag(country, class: "mt-0.5")
                div do
                  plain(country.iso_short_name)
                  whitespace
                  plain("(#{value})")
                end

                template(data: { template: "flag" }) do
                  country_flag(country)
                end
              end
            end
          end
        end
      end

      Components::Input(
        form: @form,
        field: @field,
        type: "tel",
        name: nil,
        value: phone_number&.national_number,
        autocomplete: "tel-national",
        disabled: @disabled,
        required: @required,
        **mix(
          {
            data: {
              phone_number_input_target: "nationalNumberInput",
              action: [
                "phone-number-input#normalizeNationalNumber",
                "change->phone-number-input#updateHiddenInput",
              ],
            },
          },
          @attributes,
        ),
      )

      if @form
        @form.hidden_field(@field, **hidden_field_options)
      else
        hidden_field_tag(@field, **hidden_field_options)
      end
    end
  end

  private

  # == Helpers ==

  sig { params(country: ISO3166::Country).returns(String) }
  def country_value(country)
    "+#{country.country_code}"
  end

  sig { params(country: ISO3166::Country, options: T.untyped).void }
  def country_flag(country, **options)
    Icon("flag/#{country.alpha2}", **options)
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def hidden_field_options
    {
      data: {
        phone_number_input_target: "hiddenInput",
      },
    }
  end

  sig { returns(T.nilable(Phonelib::Phone)) }
  def phone_number
    return @phone_number if defined?(@phone_number)

    @phone_number = T.let(
      if @value
        normalize_phone_number(@value)
      elsif (object = @form&.object) && @field && (value = object.public_send(@field))
        normalize_phone_number(value)
      end,
      T.nilable(Phonelib::Phone),
    )
  end

  sig { params(value: T.any(String, Phonelib::Phone)).returns(Phonelib::Phone) }
  def normalize_phone_number(value)
    case value
    when String
      Phonelib.parse(value)
    when Phonelib::Phone
      value
    end
  end

  sig { returns(ISO3166::Country) }
  def country
    @country ||= T.let(
      begin
        country_code = phone_number&.country || @default_country_code
        ISO3166::Country[country_code]
      end,
      T.nilable(ISO3166::Country),
    )
  end
end
