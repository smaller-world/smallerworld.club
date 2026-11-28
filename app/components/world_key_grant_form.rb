# typed: strict
# frozen_string_literal: true

class Components::WorldKeyGrantForm < Components::Base
  # == Initialization ==

  sig do
    params(
      grant: WorldKeyGrant,
      attributes: T.untyped,
    ).void
  end
  def initialize(grant:, **attributes)
    super(**attributes)
    @grant = grant
    @world = T.let(grant.world, World)
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @grant,
      action: [ :new, @world, :key_grant ],
      method: :get,
      **mix(
        {
          class: "world-key-grant-form",
          data: {
            controller: "submit",
            turbo_frame: "world_key_grant_form_qr_code",
          },
        },
        @attributes,
      ),
    ) do |form|
      Components::FieldSet(class: "gap-6") do |field_set|
        div(class: "flex flex-col items-center text-balance") do
          field_set.legend(class: "text-center mb-0.5") do
            "pick a key to give to your friend"
          end
          field_set.description(class: "text-center") do
            "keys control what a friend can see on your world"
          end
        end
        form.Field(:key_type_id).radios(
          @world.key_types.alphabetical,
          class: if @world.key_types.size.even?
                   "grid-cols-[min-content_min-content] place-content-center"
                 else
                   "flex flex-wrap justify-center"
                 end,
        ) do |choice|
          choice.label(
            class: "size-28 cursor-pointer has-data-checked:border-key-foreground",
            data: {
              key_color: choice.item.color,
            },
          ) do
            Components::Field(class: "w-auto my-auto items-center") do |field|
              Icon("huge/key-02", class: "size-6 text-key-foreground")
              field.content(class: "items-center") do
                field.title(class: "text-xs text-key-foreground text-center") do
                  choice.item.name
                end
              end
              choice.input(
                name: "key_type_id",
                class: "visually-hidden",
                data: {
                  action: "submit#request",
                },
              )
            end
          end
        end
        edit_key_types_button
      end

      qr_code_frame(form:)
    end
  end

  private

  # == Helpers ==

  sig { void }
  def edit_key_types_button
    Components::DropdownMenu() do |menu|
      menu.with_trigger_button(
        variant: :secondary,
        size: :xs,
        class: "self-center",
      ) do |button|
        button.inline_start_icon("huge/settings-01")
        span { "edit key types" }
      end
      menu.with_content(anchor: :bottom) do |menu_content|
        menu_content.group do
          @world.key_types.alphabetical.find_each do |key_type|
            menu_content.link_item_to(
              [ :edit, key_type ],
              class: "text-key-foreground",
              data: {
                controller: "return-to-self",
                key_color: key_type.color,
              },
            ) do
              Icon("huge/key-02")
              span do
                span(class: "text-muted-foreground group-focus/dropdown-menu-item:text-primary") { "edit " }
                plain(key_type.name)
              end
            end
          end
        end
        menu_content.separator
        menu_content.group do
          menu_content.link_item_to(
            [ :new, @world, :key_type ],
            data: {
              controller: "return-to-self",
            },
          ) do
            Icon("huge/plus-sign-square")
            span { "add a new key type" }
          end
        end
      end
    end
  end

  sig { params(form: Components::Form[WorldKeyGrant]).returns(T.untyped) }
  def qr_code_frame(form:)
    turbo_frame_tag("world_key_grant_form_qr_code", data: { slot: "qr-code-frame" }) do
      if @grant.valid? && (key_type_id = @grant.key_type_id)
        url = grant_url(key_type_id:)
        Components::Badge(class: "self-center") do
          "now, get your friend to scan this qr code:"
        end
        grant_qr_code(url)
        div(class: "flex flex-col items-center gap-2") do
          Components::Button(
            type: :button,
            variant: :secondary,
            size: :xs,
            data: {
              slot: "copy-invite-link-button",
              controller: "clipboard flash-text",
              clipboard_copy_value: url,
              flash_text_content_value: "invite link copied!",
              action: "clipboard#copy clipboard:copied->flash-text#flash",
            },
          ) do |button|
            button.inline_start_icon("huge/link-01")
            span(data: { flash_text_target: "container" }) do
              "copy invite link"
            end
          end
        end
      else
        form.error_for(:key_type_id, class: "text-center")
      end
    end
  end

  sig { params(url: String).void }
  def grant_qr_code(url)
    qr_code = RQRCode::QRCode.new(url)
    svg = qr_code.as_svg(use_path: true, viewbox: true, color: :currentColor)
    div(class: "relative", data: { slot: "grant-qr-code" }) do
      raw(safe(svg)) # rubocop:disable Rails/OutputSafety
      div(class: "absolute inset-0 flex items-center justify-center") do
        div(class: "bg-background flex items-center rounded-world-icon size-17 p-2.5") do
          image_tag(
            "logo.png",
            alt: [ SmallerWorld.application.site_name, "logo" ].join(" "),
            class: "flex-1",
          )
        end
      end
    end
  end

  sig { params(key_type_id: String).returns(String) }
  def grant_url(key_type_id:)
    message = WorldKey.grant_message(key_type_id:)
    shortlinked_url_helpers.world_key_grant_url(message:)
  end
end
