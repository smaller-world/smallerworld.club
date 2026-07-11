# typed: strict
# frozen_string_literal: true

class Components::WorldKeyWorldVisitForm < Components::Base
  include Phlex::Rails::Helpers::FormWith
  include NormalizeAttributes

  # == Initialization ==

  sig { params(world_key: WorldKey, attributes: T.untyped).void }
  def initialize(world_key:, **attributes)
    @world_key = world_key
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      url: world_key_world_visits_path(@world_key),
      data: {
        turbo: false,
        controller: "async-submission submit",
        submit_require_page_visible_value: true,
        action: "turbo:load@document->submit#request:once",
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
