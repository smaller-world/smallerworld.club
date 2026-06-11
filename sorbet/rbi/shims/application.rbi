# typed: strict

# == Test Helpers ==
#
# Test helpers are mixed into Rails' test classes at runtime via
# `ActiveSupport.on_load(...)` hooks (the Rails 8 generator idiom — see
# `test/test_helpers/session_test_helper.rb`). Sorbet doesn't execute load
# hooks during typecheck, so the inclusions are invisible unless mirrored
# here. Add a class re-open below whenever a new test helper module is
# wired up at runtime. The method sigs themselves live on the helper
# modules in `test/test_helpers/*.rb` — only the `include` needs to live
# here.

class ActiveSupport::TestCase
  include WorldTestHelper
end

class ActionDispatch::SystemTestCase
  # Tapioca's DSL RBI mixes URL helpers into ActionDispatch::IntegrationTest but
  # Sorbet's actionpack RBI declares SystemTestCase < ActiveSupport::TestCase
  # (skipping IntegrationTest in its view), so we mirror the URL helpers here.
  include GeneratedPathHelpersModule
  include GeneratedUrlHelpersModule
  include SystemSessionTestHelper
  # WorldTestHelper comes transitively via ActiveSupport::TestCase.
end

class ActionDispatch::IntegrationTest
  include PhoneNumberVerificationRequestTestHelper
  include SessionTestHelper
  include TurnstileTestHelper
  include WorldTestHelper
end

# == Application ==

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

  sig { returns(T::Boolean) }
  def ios_browser?; end
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
