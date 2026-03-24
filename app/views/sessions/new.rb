# typed: true
# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  sig { override.void }
  def view_template
    Components::Layout(title: "sign in to happy town") do |layout|
      layout.page_container(
        class: "flex flex-col items-center justify-center",
      ) do
        Components::Card(class: "w-full max-w-xs") do |card|
          card.header(class: "flex flex-col items-center gap-y-3") do
            div(class: "size-18 rounded-full overflow-hidden") do
              image_tag(
                "logo-icon.png",
                class: "size-full object-contain scale-[1.2]",
              )
            end
            card.title(class: "text-lg text-center") do
              if (name = Rails.configuration.x.site_name)
                plain("sign in to ")
                span(class: "font-bold") { name }
              else
                plain("sign in")
              end
            end
          end
          card.content do
            form_with(url: session_path) do |form|
              Components::FieldGroup() do
                Components::Field(
                  form:,
                  field: :email_address,
                ) do |field|
                  field.label { "email" }
                  Components::Input(
                    form:,
                    field: :email_address,
                    type: :email,
                    autocomplete: "username",
                    required: true,
                    placeholder: "me@example.com",
                  )
                  field.error
                end

                Components::Field(form:, field: :password) do |field|
                  div(class: "flex items-center") do
                    field.label { "password" }
                    link_to(
                      new_password_path,
                      class: "link ml-auto inline-block text-sm",
                    ) do
                      "forgot your password?"
                    end
                  end
                  Components::Input(
                    form:,
                    field: :password,
                    type: :password,
                    autocomplete: "current-password",
                    required: true,
                    maxlength: 72,
                  )
                  field.error
                end

                Components::Field() do
                  Components::Button(type: :submit, size: :lg) do
                    Icon(
                      "huge/arrow-right-02",
                      class: "size-6",
                      data: { icon: "inline-start" },
                    )
                    span(class: "text-base font-semibold") { "sign in" }
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
