# typed: strict
# frozen_string_literal: true

class Components::AccountTimeZoneForm < Components::Base
  # == Initialization ==

  sig { params(current_user: User, attributes: T.untyped).void }
  def initialize(current_user:, **attributes)
    @current_user = current_user
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @current_user,
      action: account_time_zone_path,
      data: {
        controller: "submit",
        submit_require_page_visible_value: true,
      },
      hidden: true,
    ) do |form|
      form.Field(:time_zone_name).hidden(data: {
        controller: "current-time-zone-input",
        action: "current-time-zone-input:changed->submit#request",
      })
    end
  end
end
