# typed: true
# frozen_string_literal: true

class Views::Worlds::Index < Views::Base
  # == Initialization ==

  sig { params(current_user: User).void }
  def initialize(current_user:)
    @current_user = current_user
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::Layout() do |layout|
      layout.page_container(class: "max-w-lg") do
        h1(class: "text-2xl") { "your worlds" }
        ul do
          @current_user.worlds.each do |world|
            li do
              link_to(world.name, world, class: "underline")
            end
          end
        end
      end
    end
  end
end
