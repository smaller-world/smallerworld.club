# typed: true

class ApplicationCable::Connection
  sig { params(value: T.nilable(User)).returns(T.nilable(User)) }
  def current_user=(value)
  end

  sig { returns(T.nilable(User)) }
  def current_user; end
end

class Components::Base
  include LocalTimeHelper
  include InlineSvg::ActionView::Helpers

  sig { params(text: String, options: T.untyped).returns(String) }
  def auto_link(text, **options); end
end
