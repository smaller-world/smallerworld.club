# typed: strict
# frozen_string_literal: true

module V1
  class ApplicationRecord < ActiveRecord::Base
    extend T::Sig
    extend T::Helpers

    abstract!

    include TaggedLogging

    # == Configuration ==

    self.abstract_class = true
    connects_to database: { reading: :v1, writing: :v1 }

    sig { override.returns(TrueClass) }
    def readonly? = true

    # == Scopes ==

    scope :chronological, -> { order(:created_at) }
    scope :reverse_chronological, -> { order(created_at: :desc) }

    # == Typechecking ==

    # Support runtime type-checking for Sorbet-generated types.
    PrivateRelation = ActiveRecord::Relation
    PrivateRelationWhereChain = ActiveRecord::Relation
    PrivateAssociationRelation = ActiveRecord::AssociationRelation
    PrivateAssociationRelationWhereChain = ActiveRecord::AssociationRelation
    PrivateCollectionProxy = ActiveRecord::Associations::CollectionProxy
  end
end
