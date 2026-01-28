# typed: strong

class ActionController::Base
  # include ActionPolicy::Controller
end

class ActionPolicy::Base
  sig { returns(T.noreturn) }
  def deny!; end
end

module ActionPolicy::Policy::Scoping::ClassMethods
  has_attached_class!(:out)

  sig do
    params(
      type: Symbol,
      name: T.untyped,
      block: T.proc
        .params(relation: T.untyped)
        .returns(T.untyped)
        .bind(T.attached_class),
    ).void
  end
  def scope_for(type, name = T.unsafe(nil), &block); end
end

module ActionPolicy::ScopeMatchers::ActiveRecord
  has_attached_class!(:out)

  sig do
    params(
      _arg0: T.untyped,
      _arg1: T.untyped,
      _arg2: T.proc
        .params(relation: ActiveRecord::Relation)
        .returns(ActiveRecord::Relation)
        .bind(T.attached_class),
    ).void
  end
  def relation_scope(*_arg0, **_arg1, &_arg2); end
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
  ); end
end
