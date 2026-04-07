# typed: true
# frozen_string_literal: true

class Components::SignInWithAppleButton < Components::Base
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
      url: apple_oauth_session_path,
      method: :post,
      **mix(
        {
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
      f.button(**mix({ class: "sign_in_with_apple_button" }, **@attributes)) do
        inline_svg_tag(
          "sign_in_with_apple/button_logo.svg",
          aria_hidden: true,
        )
        span do
          "Sign in with Apple"
        end
      end
    end
  end
end
