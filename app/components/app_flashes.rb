# typed: strict
# frozen_string_literal: true

class Components::AppFlashes < Components::Base
  include Phlex::Rails::Helpers::Flash

  # == Configuration ==

  FLASH_TYPES = [ :alert, :notice ]

  # == Component ==

  sig { override.void }
  def view_template
    root_element(:div, id: "flashes", class: "contents") do
      FLASH_TYPES.each do |type|
        if (message = flash[type])
          Components::AppFlashAlert(message:, type:)
        end
      end
    end
  end
end
