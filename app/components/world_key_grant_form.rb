# typed: strict
# frozen_string_literal: true

class Components::WorldKeyGrantForm < Components::Base
  # == Initialization ==

  sig do
    params(
      world: World,
      granted_post_types: T::Array[PostType],
      attributes: T.untyped,
    ).void
  end
  def initialize(world:, granted_post_types:, **attributes)
    super(**attributes)
    @world = world
    @granted_post_types = granted_post_types
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      url: [ :new, @world, :key_grant ],
      method: :get,
      **normalize_mix(
        {
          class: "flex flex-col gap-6",
          data: {
            controller: "submit",
            turbo_frame: :world_key_grant_form_qr_code,
          },
        },
        @attributes,
      ),
    ) do |form|
      post_types = @world.post_types
      Components::FieldSet(class: "gap-0") do |field_set|
        field_set.legend(class: "text-center") do
          "this key shares access to:"
        end
        checkbox_group_for(
          form,
          :granted_post_type_ids,
          class: "flex-row justify-center gap-2 flex-wrap",
        ) do |checkbox_group|
          post_types.each do |post_type|
            granted_post_type_choice_card_for(post_type, checkbox_group:)
          end
        end
      end

      turbo_frame_tag(:world_key_grant_form_qr_code) do
        div(class: class_names("flex flex-col gap-3", "hidden" => @granted_post_types.none?)) do
          span(class: "text-xs text-center text-muted-foreground italic") do
            "get your friend to scan this qr code:"
          end

          div(class: "flex flex-col gap-y-1") do
            grant_qr_code

            div(class: "flex flex-col items-center") do
              Components::Button(
                variant: :link,
                size: :sm,
                class: "text-muted-foreground text-xs",
                data: {
                  controller: "clipboard flash-text",
                  clipboard_copy_value: grant_url,
                  flash_text_content_value: "invite link copied!",
                  action: [ "clipboard#copy", "clipboard:copied->flash-text#show" ],
                },
              ) do
                "copy invite link"
              end
              p(class: "text-xs text-center text-muted-foreground max-w-52 italic") do
                "anyone with the link will be able to see your " \
                  "#{@granted_post_types.map(&:label).to_sentence} posts"
              end
            end
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(post_type: PostType, checkbox_group: Components::CheckboxGroup).void }
  def granted_post_type_choice_card_for(post_type, checkbox_group:)
    checkbox_group.field_label_for(post_type.id, class: "cursor-pointer w-fit") do |field_label|
      field_label.field(
        orientation: :horizontal,
        class: "w-auto py-1 pl-2 pr-2 items-center",
      ) do |field|
        field.content do
          field.title(class: "flex items-center gap-1.5") do
            Icon(post_type.icon, class: "size-4")
            span do
              post_type.label
            end
          end
        end
        field.checkbox_group_item_for(
          post_type.id,
          multiple: true,
          checked: @granted_post_types.include?(post_type),
          class: "rounded-full",
          input: {
            data: {
              action: "change->submit#request",
            },
          },
        )
      end
    end
  end

  sig { void }
  def grant_qr_code
    qr_code = RQRCode::QRCode.new(grant_url)
    svg = qr_code.as_svg(use_path: true, viewbox: true, color: :currentColor)
    div(class: "relative") do
      raw(safe(svg)) # rubocop:disable Rails/OutputSafety
      div(class: "absolute inset-0 flex items-center justify-center") do
        div(class: "bg-background flex items-center rounded-world-icon size-17 p-2.5") do
          image_tag(
            "logo.png",
            alt: [ Smallerworld.application.site_name, "logo" ].join(" "),
            class: "flex-1",
          )
        end
      end
    end
  end

  sig { returns(String) }
  def grant_url
    grant = @world.key_grant(post_types: @granted_post_types)
    shortlinked_url_helpers.world_key_grant_url(grant:)
  end
end
