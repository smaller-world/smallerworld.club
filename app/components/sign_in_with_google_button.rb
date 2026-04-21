# typed: true
# frozen_string_literal: true

class Components::SignInWithGoogleButton < Components::Base
  # == Initialization ==

  sig { params(form: T::Hash[Symbol, T.untyped], attributes: T.untyped).void }
  def initialize(form: {}, **attributes)
    @form_options = form
    super(**attributes)
  end

  # == Component ==

  def view_template
    rails_form_with(
      url: google_oauth_session_path,
      method: :post,
      **mix(
        {
          class: "flex flex-col items-stretch",
          data: {
            turbo: false,
          },
        },
        **@form_options,
      ),
    ) do |form|
      form.hidden_field(
        :time_zone,
        data: {
          controller: "current-time-zone-input",
        },
      )
      form.button(**mix(
        { class: "sign_in_with_google_button" },
        @attributes,
      )) do
        inline_svg_tag(
          "sign_in_with_google/button_logo.svg",
          aria_hidden: true,
          data: {
            icon: "inline-start",
          },
        )
        span do
          "Sign in with Google"
        end
      end
    end
  end
end
