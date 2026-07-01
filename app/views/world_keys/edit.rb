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

        div(class: "flex flex-col gap-1") do
          Components::WorldKeyForm(world_key: @world_key)
          Components::DropdownMenu() do |menu|
            menu.with_trigger_button(variant: :link, class: "text-muted-foreground") do
              "destroy key"
            end
            menu.with_content(anchor: :bottom, class: "min-w-none") do |menu_content|
              menu_content.label(class: "pt-1.5 pb-0.5 text-center") do
                "are you sure?"
              end
              form_with(url: @world_key, method: :delete) do
                menu_content.button_item(type: :submit, variant: :destructive) do
                  Icon("huge/delete-01")
                  span { "really destroy" }
                end
              end
            end
          end
        end
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
