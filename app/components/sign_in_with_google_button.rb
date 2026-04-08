# typed: true
# frozen_string_literal: true

class Components::SignInWithGoogleButton < Components::Base
  include Phlex::Rails::Helpers::ButtonTo

  # == Configuration ==

  sig { params(form: T::Hash[Symbol, T.untyped], attributes: T.untyped).void }
  def initialize(form: {}, **attributes)
    super(**attributes)
    @form_options = form
  end

  # == Component ==

  def view_template
    form_with(
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
    ) do |f|
      f.hidden_field(
        :time_zone,
        data: {
          controller: "current-time-zone-input",
        },
      )
      f.button(**mix({ class: "sign_in_with_google_button" }, **@attributes)) do
        inline_svg_tag(
          "sign_in_with_google/button_logo.svg",
          aria_hidden: true,
        )
        span do
          "Sign in with Google"
        end
      end
    end
  end
end
