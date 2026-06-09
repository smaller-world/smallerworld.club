# typed: strict

class ActionController::Base
  include ActionPolicy::Controller
end

module ActionPolicy::Policy::Reasons
  sig { params(reason: T.untyped).returns(T.noreturn) }
  def deny!(reason = T.unsafe(nil)); end
end

module ActionPolicy::Policy::Scoping::ClassMethods
  has_attached_class!(:out)

  sig do
    params(
      type: Symbol,
      name: T.untyped,
      callable: T.untyped,
      block: T.proc
        .params(relation: T.untyped)
        .returns(T.untyped)
        .bind(T.attached_class),
    ).void
  end
  def scope_for(type, name = T.unsafe(nil), callable = T.unsafe(nil), &block); end
end

module ActionPolicy::Behaviours::Scoping
  sig do
    type_parameters(:U).params(
      target: T.all(T.type_parameter(:U), ActiveRecord::Relation),
      type: Symbol,
      as: Symbol,
      scope_options: T::Hash[Symbol, T.untyped],
      options: T.untyped,
    ).returns(T.type_parameter(:U))
  end
  def authorized_scope(
    target,
    type: T.unsafe(nil),
    as: T.unsafe(nil),
    scope_options: T.unsafe(nil),
    **options
  )
  end
end
