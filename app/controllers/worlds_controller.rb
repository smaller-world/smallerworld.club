# typed: true
# frozen_string_literal: true

class WorldsController < ApplicationController
  # GET /worlds
  def index
    current_user = current_user!
    render Views::Worlds::Index.new(current_user:)
  end

  # GET /worlds/:id
  # GET /@:id
  def show
    world = find_world
    render Views::Worlds::Show.new(world:)
  end

  # GET /worlds/new
  def new
    current_user = current_user!
    world = current_user.worlds.build
    render Views::Worlds::New.new(world:)
  end

  # GET /worlds/:id/edit
  def edit
  end

  # POST /worlds
  def create
    current_user = current_user!
    world_params = params.expect(world: [ :name, :icon ])
    world = current_user.worlds.build(**world_params)
    if world.save
      redirect_to(world)
    else
      render Views::Worlds::New.new(world:), status: :unprocessable_content
    end
  end

  # PUT /worlds/:id
  def update
  end

  # DELETE /worlds/:id
  def destroy
  end

  private

  # == Helpers ==

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:id))
  end
end
