# typed: strict
# frozen_string_literal: true

class WorldKeyGrant
  extend T::Sig
  include ActiveModel::Model
  include ActiveModel::Attributes

  # == Initialize ==

  sig { params(params: ActionController::Parameters, world: World).void }
  def initialize(params, world:)
    super(params)
    @world = world
  end

  sig { returns(World) }
  attr_reader :world

  # == Attributes ==

  attribute :granted_post_type_ids, type: :string, array: true, default: -> { [] }

  # == Validations ==

  validates :granted_post_type_ids, presence: true

  # == Methods ==

  sig { returns(T::Enumerable[PostType]) }
  def granted_post_types
    @world.post_types.find(granted_post_type_ids)
  end
end
