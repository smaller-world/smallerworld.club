# typed: true
# frozen_string_literal: true

class WorldKeyTypesController < ApplicationController
  include Returnable

  # == Actions ==

  # GET /worlds/:world_id/key_types
  def index
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :manage?)
        render Views::WorldKeyTypes::Index.new(world:)
      end
    end
  end

  # GET /worlds/:world_id/key_types/new[?return_to=...]
  def new
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :manage?)
        key_type = world.key_types.build
        render Views::WorldKeyTypes::New.new(key_type:, return_url:)
      end
    end
  end

  # GET /world_key_types/:id/edit[?return_to=...]
  def edit
    respond_to do |format|
      format.html do
        key_type = find_key_type
        authorize!(key_type)
        render Views::WorldKeyTypes::Edit.new(key_type:, return_url:)
      end
    end
  end

  # POST /worlds/:world_id/key_types
  def create
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :manage?)
        key_type = world.key_types.build(key_type_params)
        if key_type.save
          redirect_to(return_url || [ world, :key_types ], status: :see_other)
        else
          render Views::WorldKeyTypes::New.new(key_type:, return_url:),
            status: :unprocessable_content
        end
      end
    end
  end

  # PUT/PATCH /world_key_types/:id
  def update
    respond_to do |format|
      format.html do
        key_type = find_key_type
        authorize!(key_type)
        if key_type.update(key_type_params)
          redirect_to(return_url || [ key_type.world!, :key_types ], status: :see_other)
        else
          render Views::WorldKeyTypes::Edit.new(key_type:, return_url:),
            status: :unprocessable_content
        end
      end
    end
  end

  # DELETE /world_key_types/:id
  def destroy
    respond_to do |format|
      format.html do
        key_type = find_key_type
        authorize!(key_type)
        if key_type.destroy
          redirect_to(return_url || [ key_type.world!, :key_types ], status: :see_other)
        else
          flash.now[:alert] = "failed to delete key type: #{key_type.errors.full_messages.to_sentence}"
          render Views::WorldKeyTypes::Edit.new(key_type:, return_url:),
            status: :unprocessable_content
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(WorldKeyType) }
  def find_key_type
    WorldKeyType.find(params.fetch(:id))
  end

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:world_id))
  end

  sig { returns(ActionController::Parameters) }
  def key_type_params
    params.expect(world_key_type: [ :name, :color ])
  end
end
