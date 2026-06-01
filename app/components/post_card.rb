# typed: strict
# frozen_string_literal: true

class Components::PostCard < Components::Base
  include Phlex::Rails::Helpers::DOMID

  # == Initialization ==

  sig { params(post: Post, attributes: T.untyped).void }
  def initialize(post:, **attributes)
    super(**attributes)
    @post = post
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
          class: "shadow-sm overflow-visible",
        },
        @attributes,
      ),
    ) do |card|
      card.header(class: "gap-1.5") do
        card.description(class: "flex items-end justify-between") do
          div(class: "flex gap-2 items-center") do
            if (emoji = @post.emoji)
              div(class: "font-emoji text-sm") do
                emoji
              end
            end
            local_time(@post.created_at, class: "lowercase text-xs block")
          end

          if allowed_to?(:manage?, @post)
            edit_menu(card:)
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
      card.footer(class: "flex items-end justify-between gap-6") do
        if allowed_to?(:react?, @post)
          reply_via_menu
        end

        turbo_frame_tag(
          dom_id(@post, :reactions),
          src: [ @post, :reactions ],
          loading: :lazy,
          data: {
            controller: "frame",
          },
        )
      end
    end
  end

  private

  # == Helpers ==

  sig { params(card: Components::Card).void }
  def edit_menu(card:)
    Components::DropdownMenu() do |menu|
      menu.with_trigger_button(
        variant: :outline,
        size: :xs,
        class: class_names("-mt-2" => card.size == :default),
      ) do
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
        form_with(url: @post, method: :delete) do
          content.button_item(type: :submit, variant: :destructive) do
            Icon("huge/delete-01")
            span { "delete" }
          end
        end
      end
    end
  end

  sig { void }
  def reply_via_menu
    Components::DropdownMenu() do |menu|
      menu.with_trigger_button(class: "rounded-full") do |button|
        button.inline_start_icon("huge/message-01")
        span { "reply via" }
      end

      menu.with_content(anchor: [ :bottom ]) do |content|
        User::MESSAGING_PLATFORMS.each do |platform|
          content.link_item_to(@post.reply_url(platform:)) do
            reply_platform_icon(platform)
            span { platform.to_s.humanize(capitalize: false) }
          end
        end
      end
    end
  end

  sig { params(platform: T.anything).void }
  def reply_platform_icon(platform)
    icon = case platform
    when :sms
      "huge/message-01"
    when :whatsapp
      "huge/whatsapp"
    when :telegram
      "huge/telegram"
    else
      raise ArgumentError, "Unknown platform: #{platform}"
    end
    Icon(icon)
  end
end
