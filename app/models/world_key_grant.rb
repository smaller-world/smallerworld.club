# typed: strict
# frozen_string_literal: true

class WorldKeyGrant
  extend T::Sig
  include ActiveModel::Model
  include ActiveModel::Attributes

  # == Initialize ==

  sig { params(attributes: T.untyped, world: World).void }
  def initialize(attributes = {}, world:)
    super(attributes)
    @world = world
  end

  sig { returns(World) }
  attr_reader :world

  # == Attributes ==

  attribute :key_type_id, type: :string

  # == Validations ==

  validates :key_type_id,
    inclusion: { in: :world_key_type_ids, message: "must belong to this world" },
    allow_nil: true

  private

  # == Helpers ==

  delegate :key_type_ids, to: :world, prefix: true
end
