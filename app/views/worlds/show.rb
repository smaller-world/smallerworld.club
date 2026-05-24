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
    @keys = T.let(
      if (user = Current.user)
        @world.keys.accepted.where(recipient: user).to_a
      else
        []
      end,
      T::Array[WorldKey],
    )
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(page_title: @world.name) do |layout|
      layout.page_container(class: "max-w-lg flex flex-col gap-8") do
        section(class: "flex flex-col gap-4") do
          div(class: "flex justify-between") do
            button_back_to(:home)

            if allowed_to?(:manage?, @world)
              button_link_to(
                "edit",
                [ :edit, @world ],
                icon: "huge/pencil-edit-01",
                variant: :secondary,
              )
            elsif @keys.any?
              div(class: "flex gap-0.5 justify-center self-center") do
                @keys.each do |key|
                  Components::Badge(variant: :ghost, class: "h-8 px-2", data: {
                    controller: "tippy",
                    tippy_content_value: "you've got #{key_descriptor(key)} to #{@world.name}",
                    tippy_placement_value: "bottom-end",
                  }) do
                    Icon(
                      "huge/key-02",
                      style: "color: var(--world-key-color-#{key.color})",
                      class: "size-5",
                    )
                  end
                end
              end
            end
          end

          if allowed_to?(:manage?, @world)
            Components::Card() do |card|
              card.content(class: "flex flex-col items-center gap-2") do
                image_tag(
                  @world.page_icon_variant,
                  class: "size-32 rounded-world-icon object-cover",
                )
                card.title(element: :h1, class: "text-2xl text-center") do
                  @world.name
                end
                if (blurb = @world.blurb)
                  p(class: "whitespace-pre-wrap text-center text-muted-foreground text-sm") do
                    blurb
                  end
                end
              end
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
          else
            div(class: "flex flex-col items-center gap-2 pt-6") do
              image_tag(
                @world.page_icon_variant,
                class: "size-32 rounded-world-icon object-cover",
              )
              h1(class: "text-2xl text-center") do
                @world.name
              end
              if (blurb = @world.blurb)
                p(class: "whitespace-pre-wrap text-center text-muted-foreground text-sm") do
                  blurb
                end
              end
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
            class: "text-lg font-bold rounded-full px-3 self-center gap-2",
            icon_class: "size-5",
          )
        end

        section(class: "space-y-4") do
          if @posts.any?
            ul(id: "posts", class: "space-y-4") do
              Components::WorldPostItems(posts: @posts)
            end
          else
            Components::Empty() do |empty|
              empty.header(class: "gap-0") do
                empty.media(variant: :icon) do
                  Icon("huge/message-edit-01")
                end
                empty.title do
                  "no posts yet"
                end
              end
            end
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

  private

  # == Helpers ==

  sig { params(key: WorldKey).returns(String) }
  def key_descriptor(key)
    color = key.color
    if color.match?(/^[aeiou]/i)
      "an #{color} key"
    else
      "a #{color} key"
    end
  end
end
