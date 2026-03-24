# typed: true
# frozen_string_literal: true

class Views::Passwords::Edit < Views::Base
  sig { params(user: User, token: String, options: T.untyped).void }
  def initialize(user:, token:, **options)
    super(**options)
    @user = user
    @token = token
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Layout(title: "update password") do |layout|
      layout.page_container(
        class: "flex flex-col items-center justify-center",
      ) do
        Components::Card(class: "w-full max-w-xs") do |card|
          card.header do
            card.title(class: "text-lg text-center") do
              "update your password"
            end
          end
          card.content do
            form_with(url: passwords_path(@token), method: :put) do |form|
              Components::FieldGroup() do
                Components::Field(form:, field: :password) do |field|
                  field.label { "new password" }
                  Components::Input(
                    form:,
                    field: :password,
                    type: :password,
                    autocomplete: "new-password",
                    required: true,
                    maxlength: 72,
                  )
                  field.error
                end

                Components::Field(form:, field: :password) do |field|
                  field.label { "new password (again)" }
                  Components::Input(
                    form:,
                    field: :password_confirmation,
                    type: :password,
                    autocomplete: "new-password",
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
                    span(class: "text-base") { "update password" }
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
