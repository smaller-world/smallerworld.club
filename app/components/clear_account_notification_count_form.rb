# typed: strict
# frozen_string_literal: true

class Components::ClearAccountNotificationCountForm < Components::Base
  # == Initialization ==

  sig { params(current_user: User, attributes: T.untyped).void }
  def initialize(current_user:, **attributes)
    @current_user = current_user
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    if @current_user.has_uncleared_notifications?
      form_with(
        url: clear_account_notification_count_path,
        data: {
          controller: "submit connection",
          action: "connection:connect->submit#request",
        },
        html: {
          hidden: true,
        },
      )
    end
  end
end
