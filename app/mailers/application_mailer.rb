# typed: strict
# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  extend T::Sig

  # == Configuration ==

  default from: "smaller world <app@smallerworld.club>",
    reply_to: ActionMailer::Base.email_address_with_name(
      Smallerworld.application.contact_email,
      "smaller world team",
    )
  layout false

  private

  # == Helpers ==

  sig do
    params(renderable: T.untyped, subject: String, to: String, options: T.untyped)
      .returns(Mail::Message)
  end
  def render_email(renderable, subject:, to:, **options)
    mail(subject:, to:, **options) do |format|
      format.html do
        render renderable
      end
    end
  end
end
