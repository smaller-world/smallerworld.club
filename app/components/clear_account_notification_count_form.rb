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
    form_with(
      url: clear_account_notification_count_path,
      data: {
        controller: "submit connection notification-badge-count-bridge",
        submit_require_page_visible_value: true,
        action: token_list(
          "turbo:submit-end->notification-badge-count-bridge#clear",
          "connection:connect->submit#request" =>
            @current_user.has_uncleared_notifications?,
        ),
      },
      html: {
        hidden: true,
      },
    )
  end
end
