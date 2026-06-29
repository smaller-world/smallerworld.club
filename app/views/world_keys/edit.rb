# typed: strict
# frozen_string_literal: true

class Views::WorldKeys::Edit < Views::Base
  # == Initialization ==

  sig { params(world_key: WorldKey).void }
  def initialize(world_key:)
    super()
    @world_key = world_key
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      page_title: "edit #{world_key_recipient.name}'s key",
    ) do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          world = @world_key.world!
          button_back_to("your friends", [ world, :keys ], variant: :secondary)
        end

        Components::WorldKeyForm(world_key: @world_key)
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(User) }
  def world_key_recipient
    @world_key.recipient!
  end
end
