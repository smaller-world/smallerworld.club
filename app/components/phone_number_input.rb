# typed: true
# frozen_string_literal: true

class Components::PhoneNumberInput < Components::Input
  include Phlex::Rails::Helpers::HiddenFieldTag

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      default_country_code: String,
      options: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, default_country_code: "CA", **options)
    @default_country = T.let(ISO3166::Country[default_country_code], ISO3166::Country)
    super(form:, field:, **options)
  end

  # == Component ==

  sig { override.void }
  def view_template
    div(class: "flex gap-2", data: { controller: "phone-number-input" }) do
      Components::Combobox(
        input: {
          type: "tel",
          autocomplete: "off",
          value: country_value(@default_country),
          required: true,
          class: "field-sizing-content px-2",
          data: {
            phone_number_input_target: "countryCodeInput",
            action: [
              "keydown.enter->phone-number-input#normalizeCountryCode:capture",
              "change->phone-number-input#guessCountryCodeIfNeeded",
            ],
            country_code: @default_country.alpha2,
          },
        },
      ) do |combobox|
        combobox.with_inline_start_addon(
          data: {
            phone_number_input_target: "countryFlagAddon",
          },
        ) do
          country_flag(@default_country)
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
        autocomplete: "tel-national",
        **mix(
          {
            data: {
              phone_number_input_target: "nationalNumberInput",
              action: "change->phone-number-input#updateHiddenInput",
            },
          },
          @options,
        ),
      )

      if @form && @field
        @form.hidden_field(@field, **hidden_field_options)
      else
        hidden_field_tag(**hidden_field_options)
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
end
