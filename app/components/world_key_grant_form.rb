# typed: strict
# frozen_string_literal: true

class Components::WorldKeyGrantForm < Components::Base
  # == Initialization ==

  sig { params(world: World, key_color: T.nilable(Symbol), attributes: T.untyped).void }
  def initialize(world:, key_color:, **attributes)
    super(**attributes)
    @world = world
    @key_color = key_color
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(url: [ :new, @world, :key_grant ], method: :get, **normalize_mix(
      {
        class: "flex flex-col gap-6",
        data: {
          controller: "form",
        },
      },
      @attributes,
    )) do |form|
      radio_group_for(
        form,
        :key_color,
        class: "flex flex-wrap max-w-96 self-center justify-center",
      ) do |group|
        WorldKey.color.values.each do |color|
          group.field_label_for(color, class: "w-30 cursor-pointer py-1 justify-center") do |label|
            label.field(class: "items-center") do |field|
              Icon(
                "huge/key-02",
                class: "size-8",
                style: "color: var(--world-key-color-#{color})",
              )
              field.title(
                class: "text-center text-balance text-xs font-heading text-muted-foreground w-auto",
              ) do
                @world.key_label(color:)
              end
              field.radio_group_item_for(
                color,
                checked: color == @key_color,
                class: "hidden",
                input: {
                  data: {
                    action: "change->form#requestSubmit",
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
                  clipboard_copy_value: world_key_grant_url(@key_color),
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
    qr_code = RQRCode::QRCode.new(world_key_grant_url(key_color))
    svg = qr_code.as_svg(use_path: true, viewbox: true, color: :currentColor)
    div(class: "relative") do
      raw(safe(svg)) # rubocop:disable Rails/OutputSafety
      div(class: "absolute inset-0 flex items-center justify-center") do
        div(class: "bg-background flex items-center rounded-world-icon size-17 p-2.5") do
          image_tag(
            "logo.png",
            alt: [ Rails.configuration.x.site.name, "logo" ].compact.join(" "),
            class: "flex-1",
          )
        end
      end
    end
  end

  sig { params(key_color: Symbol).returns(String) }
  def world_key_grant_url(key_color)
    grant = @world.key_grant(color: key_color)
    shortlinked_url_helpers.world_key_grant_url(grant:)
  end
end
