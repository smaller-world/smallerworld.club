# typed: true

class ApplicationCable::Connection
  sig { params(value: T.nilable(User)).returns(T.nilable(User)) }
  def current_user=(value)
  end

  sig { returns(T.nilable(User)) }
  def current_user; end
end

class User
  sig { params(token: String).returns(T.nilable(User)) }
  def self.find_by_password_reset_token(token: String); end

  sig { params(token: String).returns(User) }
  def self.find_by_password_reset_token!(token: String); end
end

class Components::Base
  include LocalTimeHelper

  sig { params(text: String, options: T.untyped).returns(String) }
  def auto_link(text, **options); end
end
