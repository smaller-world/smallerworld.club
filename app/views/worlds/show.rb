# typed: true
# frozen_string_literal: true

class Views::Worlds::Show < Views::Base
  # == Fragments ==

  class PostItems < Components::Base
    sig { params(posts: T::Enumerable[Post]).void }
    def initialize(posts:)
      @posts = posts
      super()
    end

    sig { override.void }
    def view_template
      @posts.each do |post|
        li do
          Components::PostCard(post:)
        end
      end
    end
  end

  class NextPageControl < Components::Base
    sig { params(world: World, pagy: T.nilable(Pagy), options: T.untyped).void }
    def initialize(world:, pagy:, **options)
      @world = world
      @pagy = pagy
      @options = options
      super()
    end

    sig { override.void }
    def view_template
      render Components::NextPageControl.new(
        target: @world,
        pagy: @pagy,
        autoclick: true,
        **@options,
      ) do
        Icon("huge/loading-03", data: { icon: "inline-start" })
        span { "load more" }
      end
    end
  end

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
    Components::Layout() do |layout|
      layout.page_container(class: "max-w-lg space-y-8") do
        section(class: "space-y-4") do
          div(class: "flex justify-between") do
            if current_user == @world.owner
              button_back_to(:home)
            else
              div
            end

            button_link_to(
              "edit",
              [ :edit, @world ],
              icon: "huge/pencil-edit-01",
              variant: :secondary,
            )
          end

          Components::Card() do |card|
            card.header(class: "flex flex-col items-center gap-y-2") do
              image_tag(@world.page_icon_variant, class: "size-24 rounded-world-icon")
              card.title(element: :h1, class: "text-xl text-center") do
                @world.name
              end
            end
            card.content do
              "welcome to my lovely world..."
              # Components::WorldForm(world: @world)
            end
          end

          button_link_to(
            [ :new, @world, :post ],
            variant: :default,
            size: :lg,
            icon: "huge/quill-write-02",
            class: "w-full",
          ) do
            span(class: "text-base font-bold") { "new post" }
          end
        end

        section(class: "space-y-4") do
          ul(id: "posts", class: "space-y-4") do
            render PostItems.new(posts: @posts)
          end

          if @pagy.nil? || @pagy.next
            div(class: "flex flex-col items-center") do
              render NextPageControl.new(world: @world, pagy: @pagy)
            end
          end
        end
      end
    end
  end
end
