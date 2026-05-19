# typed: true

#
class ActionController::Base
  include ActionPolicy::Controller
end

module ActionPolicy::Policy::Reasons
  sig { params(reason: T.untyped).returns(T.noreturn) }
  def deny!(reason = T.unsafe(nil)); end
end
