# typed: true

class ApplicationCable::Connection
  sig { params(value: T.nilable(User)).returns(T.nilable(User)) }
  def current_user=(value)
  end

  sig { returns(T.nilable(User)) }
  def current_user; end
end

class ApplicationPolicy
  sig { returns(T.nilable(User)) }
  def user; end
end

class Components::Base
  include LocalTimeHelper
  include InlineSvg::ActionView::Helpers
  include ActionPolicy::Behaviour

  sig { params(text: String, options: T.untyped).returns(String) }
  def auto_link(text, **options); end

  sig { returns(T::Boolean) }
  def authenticated?; end
end

class Current
  sig { params(args: T.untyped, kwargs: T.untyped, block: T.untyped).returns(User) }
  def self.user(*args, **kwargs, &block); end
end

# class ActiveRecord::Migration::Current
#   sig do
#     params(
#       table_name: String,
#       options: T.untyped,
#       block: T.proc.params(t: ActiveRecord::ConnectionAdapters::TableDefinition).void,
#     ).void
#   end
#   def change_table(table_name, **options, &block)
#   end
# end
