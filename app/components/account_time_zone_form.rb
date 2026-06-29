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
    form_with(
      model: @current_user,
      url: account_time_zone_path,
      data: { controller: "submit" },
      html: { hidden: true },
    ) do |form|
      form.hidden_field(
        :time_zone_name,
        data: {
          controller: "current-time-zone-input",
          action: "current-time-zone-input:changed->submit#request",
        },
      )
    end
  end
end
