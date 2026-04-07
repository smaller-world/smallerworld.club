# typed: true
# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(
      title: "sign in to smaller world",
      body_class: "bg-muted",
    ) do |layout|
      main(class: "flex-1 flex flex-col justify-center pb-20") do
        layout.page_container(
          class: "flex flex-col items-center justify-center",
        ) do
          render_card
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def render_card
    Components::Card(class: "w-full max-w-xs") do |card|
      card.header(class: "flex flex-col items-center gap-y-3") do
        image_tag("logo.png", class: "size-10")
        card.title(class: "text-lg text-center") do
          if (site_name = Rails.configuration.x.site.name)
            plain("sign in to ")
            span(class: "font-semibold") { site_name }
          else
            plain("sign in")
          end
        end
      end
      card.content do
        Components::SignInWithAppleButton(class: "w-full")
        #   Components::Field(form:, field: :password) do |field|
        #     div(class: "flex items-center") do
        #       field.label { "password" }
        #       link_to(
        #         new_password_path,
        #         class: "link ml-auto inline-block text-sm",
        #       ) do
        #         "forgot your password?"
        #       end
        #     end
        #     Components::Input(
        #       form:,
        #       field: :password,
        #       type: :password,
        #       autocomplete: "current-password",
        #       required: true,
        #       maxlength: 72,
        #     )
        #     field.error
        #   end

        #   Components::Field() do
        #     Components::Button(type: :submit, size: :lg) do
        #       Icon(
        #         "huge/arrow-right-02",
        #         class: "size-6",
        #         data: { icon: "inline-start" },
        #       )
        #       span(class: "text-base font-semibold") { "sign in" }
        #     end
        #   end
        # end
        # end
      end
    end
  end
end
