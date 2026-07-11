# typed: strict
# frozen_string_literal: true

class Components::AccountAppVisitForm < Components::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ControllerPath
  include NormalizeAttributes

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
      url: account_app_visits_path,
      data: {
        turbo: false,
        controller: "async-submission submit notification-badge-count-bridge",
        submit_require_page_visible_value: true,
        action: token_list(
          "turbo:submit-end->notification-badge-count-bridge#clear",
          "turbo:load@document->submit#request:once",
        ),
      },
      html: {
        hidden: true,
        **normalize_attributes(@attributes),
      },
    ) do
      # NOTE: Keep block open unless you want rendering errors.
    end
  end
end
