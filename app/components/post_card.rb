# typed: true
# frozen_string_literal: true

class Components::PostCard < Components::Base
  include Phlex::Rails::Helpers::DOMID

  # == Initialization ==

  sig { params(post: Post, attributes: T.untyped).void }
  def initialize(post:, **attributes)
    @post = post
    @author = T.let(post.author!, User)
    @world = T.let(post.world!, World)
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    attributes = mix(
      {
        id: dom_id(@post),
        class: "gap-2",
      },
      @attributes,
    )
    Components::Card(**attributes) do |card|
      card.header do
        card.description(class: "text-xs") do
          local_time(@post.created_at, class: "lowercase")
        end
        if (title = @post.title)
          card.title(class: "text-xl font-semibold font-heading") do
            title
          end
          card.action do
            render_dropdown_menu
          end
        else
          card.action(class: "w-14 relative self-stretch") do
            render_dropdown_menu(class: "absolute right-0 bottom-0")
          end
        end
      end
      card.content do
        p(class: "whitespace-pre-line") do
          @post.body.to_s
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(attributes: T.untyped).void }
  def render_dropdown_menu(**attributes)
    Components::DropdownMenu(anchor: [ :bottom, :end ]) do |menu|
      menu.trigger do
        Components::Button(
          variant: :secondary,
          size: :xs,
          **attributes,
        ) do
          div(class: "relative h-full w-1.5") do
            div(class: "absolute top-0 bottom-0 -left-1.5 flex items-center") do
              Icon("huge/more-vertical", class: "size-4")
            end
          end
          span { "edit" }
        end
      end
      menu.content do
        menu.link_item(href: edit_post_path(@post)) do
          Icon("huge/pencil-edit-01")
          span { "edit" }
        end
        form_with(url: post_path(@post), method: :delete) do
          menu.button_item(variant: :destructive) do
            Icon("huge/delete-01")
            span { "delete" }
          end
        end
      end
    end
  end
end
