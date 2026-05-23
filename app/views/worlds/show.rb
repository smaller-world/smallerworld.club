# typed: true
# frozen_string_literal: true

class Views::Worlds::Show < Views::Base
  # == Initialization ==

  sig do
    params(
      world: World,
      posts: T::Enumerable[Post],
      pagy: T.nilable(Pagy),
    ).void
  end
  def initialize(world:, posts:, pagy:)
    @world = world
    @posts = posts
    @pagy = pagy
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(page_title: @world.name) do |layout|
      layout.page_container(class: "max-w-lg space-y-8") do
        section(class: "space-y-4") do
          div(class: "flex justify-between") do
            button_back_to(:home)

            if allowed_to?(:manage?, @world)
              button_link_to(
                "edit",
                [ :edit, @world ],
                icon: "huge/pencil-edit-01",
                variant: :secondary,
              )
            elsif (user = current_user) &&
                (keys = @world.keys.where(recipient: user).presence)
              div(class: "flex gap-0.5 justify-center self-center") do
                keys.each do |key|
                  Components::Badge(variant: :ghost, class: "h-6 px-1.5 [&>svg]:size-4") do
                    Icon(
                      "huge/key-02",
                      style: "color: var(--world-key-color-#{key.color})",
                    )
                  end
                end
              end
            end
          end

          Components::Card() do |card|
            card.header(class: "flex flex-col items-center gap-y-2") do
              image_tag(
                @world.page_icon_variant,
                class: "size-24 rounded-world-icon object-cover",
              )
              card.title(element: :h1, class: "text-xl text-center") do
                @world.name
              end
            end
            card.content(class: "text-center") do
              "welcome to my lovely world..."
              # Components::WorldForm(world: @world)
            end
            if allowed_to?(:manage?, @world)
              card.footer(class: "flex gap-2 justify-center") do
                button_link_to(
                  "your friends",
                  [ @world, WorldKey ],
                  variant: :secondary,
                  icon: "huge/user-group",
                )
                button_link_to(
                  "invite a friend to your world",
                  [ :new, @world, :key_grant ],
                  variant: :secondary,
                  icon: "huge/user-add-01",
                )
              end
            end
          end

          if allowed_to?(:manage?, @world)
            button_link_to(
              "new post",
              [ :new, @world, :post ],
              variant: :default,
              size: :lg,
              icon: "huge/quill-write-02",
              class: "w-full text-base font-bold",
            )
          end
        end

        section(class: "space-y-4") do
          ul(id: "posts", class: "space-y-4") do
            Components::WorldPostItems(posts: @posts)
          end

          if @pagy.nil? || @pagy.next
            div(class: "flex flex-col items-center") do
              Components::WorldNextPageControl(world: @world, pagy: @pagy)
            end
          end
        end
      end
    end
  end
end
