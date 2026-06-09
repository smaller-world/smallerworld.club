# typed: strict

class ApplicationCable::Connection
  sig { params(value: T.nilable(User)).returns(T.nilable(User)) }
  def current_user=(value); end

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

  sig { returns(T::Boolean) }
  def hotwire_native_app?; end
end

class Current
  sig { returns(T.nilable(Session)) }
  def self.session; end

  sig do
    params(args: T.untyped, kwargs: T.untyped, block: T.untyped)
      .returns(T.nilable(User))
  end
  def self.user(*args, **kwargs, &block); end
end

class ActionDispatch::Routing::RouteSet
  sig do
    params(supports_path: TrueClass).returns(T.all(
      T::Module[T.anything],
      GeneratedUrlHelpersModule,
      GeneratedPathHelpersModule,
    ))
  end
  sig do
    params(supports_path: FalseClass).returns(GeneratedUrlHelpersModule)
  end
  def url_helpers(supports_path = true); end
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
