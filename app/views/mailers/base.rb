# typed: strict
# frozen_string_literal: true

# `Views::Mailer::Base` is an abstract class for all emails.
class Views::Mailers::Base < Views::Base
  include MailerElements

  abstract!
end
