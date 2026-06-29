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
    form_with(url: [ :new, @world, :key_grant ], method: :get, **normalize_mix(
      {
        class: "flex flex-col gap-6",
        data: {
          controller: "submit",
        },
      },
      @attributes,
    )) do |form|
      Components::Card(size: :sm) do |card|
        card.content do
          Components::FieldSet(class: "gap-2") do |field_set|
            field_set.legend(class: "mb-0 text-center") do
              "this key shares access to:"
            end
            checkbox_group_for(
              form,
              :granted_post_type_ids,
              class: "flex-row justify-center gap-2 flex-wrap",
            ) do |checkbox_group|
              @world.post_types.each do |post_type|
                granted_post_type_choice_card_for(post_type, checkbox_group:)
              end
            end
          end
        end
      end

      div(class: "flex flex-col gap-3") do
        span(class: "text-xs text-center text-muted-foreground italic") do
          "get your friend to scan this qr code:"
        end

        div(class: "flex flex-col gap-y-1") do
          grant_qr_code

          Components::Button(
            variant: :link,
            size: :sm,
            class: "self-center text-muted-foreground text-xs",
            data: {
              controller: "clipboard flash",
              clipboard_copy_value: grant_url,
              flash_text_value: "invite link copied!",
              action: [ "clipboard#copy", "clipboard:copied->flash#show" ],
            },
          ) do
            "copy invite link"
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(post_type: PostType, checkbox_group: Components::CheckboxGroup).void }
  def granted_post_type_choice_card_for(post_type, checkbox_group:)
    checkbox_group.field_label_for(
      post_type.id,
      **compact_mix(
        {
          class: class_names(
            "cursor-pointer w-fit",
            "border-none bg-transparent" => !post_type.secret?,
          ),
        },
        nonsecret_post_type_label_attributes(post_type),
      ),
    ) do |field_label|
      field_label.field(
        orientation: :horizontal,
        class: class_names(
          "w-auto py-1 items-center",
          post_type.icon? ? "pl-2" : "pl-3",
          post_type.secret? ? "pr-2" : "pr-3",
        ),
        data: {
          disabled: ("true" unless post_type.secret?),
        },
      ) do |field|
        field.content do
          field.title(class: "flex items-center gap-1.5") do
            if (icon = post_type.icon)
              Icon(icon, class: "size-4")
            end
            span do
              post_type.label
            end
          end
        end
        field.checkbox_group_item_for(
          post_type.id,
          multiple: true,
          checked: @granted_post_types.include?(post_type),
          **compact_mix(
            {
              class: "rounded-full",
              input: {
                data: {
                  action: "change->submit#request",
                },
              },
            },
            nonsecret_post_type_checkbox_attributes(post_type),
          ),
        )
      end
    end
  end

  sig { params(post_type: PostType).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def nonsecret_post_type_label_attributes(post_type)
    unless post_type.secret?
      {
        data: {
          disabled: "true",
          controller: "tippy",
          tippy_content_value:
            "only secret post types can be selectively shown to friends!",
          tippy_max_width_value: "calc(60 * var(--spacing))",
        },
      }
    end
  end

  sig { params(post_type: PostType).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def nonsecret_post_type_checkbox_attributes(post_type)
    unless post_type.secret?
      {
        disabled: true,
        checked: true,
        input: {
          name: nil,
        },
      }
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
