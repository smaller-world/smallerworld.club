# typed: true
# frozen_string_literal: true

class Components::WorldKeyGrantForm < Components::Base
  include Shortlinking

  # == Initialization ==

  sig { params(world: World, key_color: T.nilable(Symbol), attributes: T.untyped).void }
  def initialize(world:, key_color:, **attributes)
    @world = world
    @key_color = key_color
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      url: [ :new, @world, :key_grant ],
      method: :get,
      class: "flex flex-col gap-6",
      data: {
        controller: "form",
      },
    ) do |form|
      radio_group_for(
        form,
        :key_color,
        class: "flex flex-wrap max-w-96 self-center justify-center",
      ) do |group|
        WorldKey.color.values.each do |color|
          group.field_label_for(color, class: "w-26 cursor-pointer py-1") do |label|
            label.field do |field|
              field.content(class: "items-center") do
                Icon(
                  "huge/key-02",
                  class: "size-10",
                  style: "color: var(--world-key-color-#{color})",
                )
                field.title(
                  class: "text-center text-xs font-heading text-muted-foreground",
                ) do
                  plain(color)
                  whitespace
                  plain("key")
                end
              end
              field.radio_group_item(
                value: color,
                checked: color == @key_color,
                class: "hidden",
                input: {
                  data: {
                    action: "change->form#submit",
                  },
                },
              )
            end
          end
        end
      end

      div(class: "flex flex-col gap-3") do
        span(class: "text-xs text-center text-muted-foreground italic") do
          if @key_color
            "get your friend to scan this qr code:"
          else
            "pick a color!"
          end
        end

        if @key_color
          div(class: "flex flex-col gap-y-1") do
            qr_code(@key_color)
            if Rails.env.development?
              Components::Button(
                variant: :link,
                size: :sm,
                class: "self-center text-muted-foreground text-xs",
                data: {
                  controller: "clipboard flash",
                  clipboard_copy_value: new_world_key_url(@key_color),
                  flash_text_value: "copied!",
                  action: [ "clipboard#copy", "clipboard:copied->flash#show" ],
                },
              ) do
                "copy url (for development)"
              end
            end
          end

        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(key_color: Symbol).void }
  def qr_code(key_color)
    qr_code = RQRCode::QRCode.new(new_world_key_url(key_color))
    svg = qr_code.as_svg(use_path: true, viewbox: true, color: :currentColor)
    raw(safe(svg)) # rubocop:disable Rails/OutputSafety
  end

  sig { params(key_color: Symbol).returns(String) }
  def new_world_key_url(key_color)
    grant = @world.key_grant(color: key_color)
    shortlinked.new_world_key_url(grant:)
  end
end
