# typed: strict

module Enumerize
  include Base::ClassMethods
  include Base::ClassMethods::Hook
  include Predicates
  include ActiveModelAttributesSupport
  include ActiveRecordSupport
  include Scope::ActiveRecord
  include ModuleAttributes
end

class Enumerize::Attribute
  sig { returns(T::Array[Enumerize::Value]) }
  def values; end
end
