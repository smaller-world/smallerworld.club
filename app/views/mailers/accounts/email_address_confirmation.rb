# typed: strict
# frozen_string_literal: true

class Views::Mailers::Accounts::EmailAddressConfirmation < Views::Mailers::Base
  # == Initialization ==

  sig { params(user: User).void }
  def initialize(user:)
    super()
    @user = user
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::MailerLayout() do |mailer_layout|
      mailer_layout.email_container do
        h1(class: "text-2xl") do
          "confirm your email address"
        end

        p(class: "mt-4") do
          "a smaller world account was created with this email address. if this was you, " \
            "please confirm your email by pressing the button below:"
        end

        email_button_to(confirmation_url, class: "mt-6 mb-3") do
          "confirm email address"
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def confirmation_url
    @confirmation_url ||= T.let(
      account_email_address_confirmation_url(
        confirmation_token: @user.generate_email_address_confirmation_token,
      ),
      T.nilable(String),
    )
  end
end
