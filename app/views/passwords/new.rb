# typed: true
# frozen_string_literal: true

class Views::Passwords::New < Views::Base
  sig { params(email_address: T.nilable(String), options: T.untyped).void }
  def initialize(email_address: nil, **options)
    super(**options)
    @email_address = email_address
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Layout(title: "forgot your password?") do |layout|
      layout.page_container(
        class: "flex flex-col items-center justify-center",
      ) do
        Components::Card(class: "w-full max-w-xs") do |card|
          card.header do
            card.title(class: "text-lg text-center") do
              "forgot your password?"
            end
          end
          card.content do
            form_with(url: passwords_path) do |form|
              Components::FieldGroup() do
                Components::Field(form:, field: :email_address) do |field|
                  field.label { "email" }
                  Components::Input(
                    form:,
                    field: :email_address,
                    type: :email,
                    autocomplete: "username",
                    required: true,
                    placeholder: "me@example.com",
                    value: @email_address,
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
                    span(class: "text-base") { "send password reset email" }
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
