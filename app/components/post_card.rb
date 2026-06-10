# typed: strict
# frozen_string_literal: true

class Components::PostCard < Components::Base
  include Phlex::Rails::Helpers::DOMID

  # == Initialization ==

  sig { params(post: Post, replied_post_ids: T::Set[String], attributes: T.untyped).void }
  def initialize(post:, replied_post_ids:, **attributes)
    super(**attributes)
    @post = post
    @replied_post_ids = replied_post_ids
    @author = T.let(post.author!, User)
    @world = T.let(post.world!, World)
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Card(
      id: dom_id(@post),
      size: hotwire_native_app? ? :sm : :default,
      **mix(
        {
          class: class_names(
            "shadow-sm overflow-visible",
            "bg-card/50 border border-dashed border-foreground/10 ring-0" => @post.selectively_shown?,
          ),
        },
        @attributes,
      ),
    ) do |card|
      card.header(class: "gap-1.5") do
        card.description(class: "flex items-end gap-2") do
          div(class: "flex-1 flex gap-2 items-center") do
            if (emoji = @post.emoji)
              div(class: "font-emoji text-sm") do
                emoji
              end
            end
            local_time(@post.created_at, class: "lowercase text-xs block")
          end

          if allowed_to?(:manage?, @post)
            div(class: "flex gap-1.5 items-center -my-1") do
              world_key_badges
              edit_menu(card:)
            end
          end
        end
        if (title = @post.title)
          card.title(class: "text-lg font-semibold font-heading leading-tight") do
            title
          end
        end
      end
      card.content(class: class_names(
        "flex flex-col gap-6",
        card.size == :sm ? "-mt-2" : "-mt-5",
      )) do
        div(class: "text-sm") do
          @post.body.to_s
        end
        if (images = @post.image_thumbnails.presence)
          Components::ImageStack(images:)
        end
      end

      if allowed_to?(:reply?, @post) || @post.reactions.any?
        card.footer(class: "flex items-end gap-6") do
          if allowed_to?(:reply?, @post)
            Components::ReplyInitiationForm(
              reply_initiation: @post.reply_initiations.build,
              replied_post_ids: @replied_post_ids,
            )
          end

          turbo_frame_tag(
            dom_id(@post, :reactions),
            src: [ @post, :reactions ],
            loading: :lazy,
            class: "flex-1",
            data: {
              controller: "frame",
            },
          ) do
            Components::Button(
              element: :div,
              variant: :ghost,
              size: :icon,
              class: "rounded-full skeleton",
            ) do
              span(class: "font-emoji text-lg") do
                "🤣"
              end
            end
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(card: Components::Card).void }
  def edit_menu(card:)
    Components::DropdownMenu() do |menu|
      menu.with_trigger_button(variant: :outline, size: :xs) do
        div(class: "relative h-full w-1.5") do
          div(class: "absolute bottom-0 top-0 -left-1.25 flex items-center") do
            Icon("huge/more-vertical", class: "size-3.5")
          end
        end
        span { "edit" }
      end

      menu.with_content(anchor: [ :bottom, :end ]) do |content|
        content.link_item_to([ :edit, @post ]) do
          Icon("huge/pencil-edit-01")
          span { "edit" }
        end
        form_with(url: @post, method: :delete, data: {
          controller: "haptic-bridge",
          action: "turbo:submit-end->haptic-bridge#vibrate",
        }) do
          content.button_item(type: :submit, variant: :destructive) do
            Icon("huge/delete-01")
            span { "delete" }
          end
        end
      end
    end
  end

  sig { void }
  def world_key_badges
    div(class: "flex gap-1 items-center") do
      if (colors = @post.key_colors)
        colors.each do |color|
          Components::Badge(variant: :secondary, class: "px-1.5") do
            Icon("huge/key-02", style: "color: var(--world-key-color-#{color})")
          end
        end
        if colors.empty?
          Components::Badge(
            variant: :secondary,
            class: "px-1.5 text-muted-foreground",
          ) do
            Icon("huge/square-lock-01")
          end
        end
      end
    end
  end
end
