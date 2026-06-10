# typed: strict
# frozen_string_literal: true

class Components::DevicePassesForm < Components::Base
  # == Initialization ==

  sig { params(url: T.untyped, attributes: T.untyped).void }
  def initialize(url:, **attributes)
    @url = url
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      url: @url,
      method: :get,
      **normalize_mix(
        {
          data: {
            controller: "device-passes-form passes-bridge",
            action: "passes-bridge:received->device-passes-form#submitPasses",
          },
          html: {
            hidden: true,
          },
        },
        @attributes,
      ),
    ) do |form|
      template(data: { device_passes_form_target: "inputTemplate" }) do
        form.hidden_field(
          :pass_serial_numbers,
          multiple: true,
          value: nil,
          data: {
            device_passes_form_target: "input",
          },
        )
      end
    end
  end
end
