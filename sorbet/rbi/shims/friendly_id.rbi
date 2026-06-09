# typed: strict

module FriendlyId
  include FriendlyId::Base
end

module FriendlyId::Base
  sig { returns(FriendlyId::Configuration) }
  def friendly_id_config; end
end

module FriendlyId::Slugged
  sig { returns(T::Boolean) }
  def should_generate_new_friendly_id?; end
end

class FriendlyId::Slug
  module GeneratedAssociationMethods
    include ActiveRecord::Base::GeneratedAssociationMethods
  end
end
