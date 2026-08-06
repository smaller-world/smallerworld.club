# typed: strict
# frozen_string_literal: true

class Components::WorldKeyGrantForm < Components::Base
  include Phlex::Rails::Helpers::FormWith
  include NormalizeAttributes

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
      Components::FieldSet() do |field_set|
        field_set.legend(class: "text-center mb-0") do
          "this key shares access to:"
        end
        form.Field(:granted_post_type_ids).checkboxes(
          @world.post_types,
          include_hidden: false,
          class: "flex-row justify-center gap-2 flex-wrap",
        ) do |choice|
          choice.label(class: "cursor-pointer w-fit") do
            Components::Field(
              orientation: :horizontal,
              invalid: form.invalid?(:granted_post_type_ids),
              class: "w-auto py-1 pl-2 pr-2 items-center",
            ) do |field|
              field.content do
                field.title(class: "flex items-center gap-1.5") do
                  Icon(choice.item.icon, class: "size-4")
                  span do
                    choice.item.label
                  end
                end
              end
              choice.input(
                name: "granted_post_type_ids[]",
                class: "rounded-full",
                data: {
                  action: "submit#request",
                },
              )
            end
          end
        end
      end

      turbo_frame_tag("world_key_grant_form_qr_code", data: {
        slot: "qr-code-frame",
      }) do
        if @grant.valid?
          Components::Badge(class: "self-center") do
            "now, get your friend to scan this qr code:"
          end
          grant_qr_code
          div(class: "flex flex-col items-center gap-2") do
            Components::Button(
              type: :button,
              variant: :secondary,
              size: :xs,
              data: {
                slot: "copy-invite-link-button",
                controller: "clipboard flash-text",
                clipboard_copy_value: grant_url,
                flash_text_content_value: "invite link copied!",
                action: "clipboard#copy clipboard:copied->flash-text#flash",
              },
            ) do |button|
              button.inline_start_icon("huge/link-01")
              span(data: { flash_text_target: "container" }) do
                "copy invite link"
              end
            end
            p(data: { slot: "copy-invite-link-description" }) do
              "anyone with the link will be able to see your " \
                "#{granted_post_types_descriptor} posts"
            end
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def grant_qr_code
    qr_code = RQRCode::QRCode.new(grant_url)
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

  sig { returns(String) }
  def grant_url
    message = @world.key_grant_message(post_type_ids: @grant.granted_post_type_ids)
    shortlinked_url_helpers.world_key_grant_url(message:)
  end

  sig { returns(String) }
  def granted_post_types_descriptor
    @grant.granted_post_types.map(&:label).to_sentence
  end
end
