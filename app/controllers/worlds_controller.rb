# typed: true
# frozen_string_literal: true

class WorldsController < ApplicationController
  # == Configuration ==

  skip_verify_authorized only: [ :new, :create ]

  # == Actions ==

  # GET /worlds
  def index
    # respond_to do |format|
    #   format.html do
    #     current_user = current_user!
    #     render Views::Worlds::Index.new(current_user:)
    #   end
    # end
  end

  # GET /worlds/:id
  # GET /@:id
  def show
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world)
        celebrate = !!params[:celebrate]
        render Views::Worlds::Show.new(world:, celebrate:)
      end
    end
  end

  # GET /worlds/new
  def new
    respond_to do |format|
      format.html do
        current_user = Current.user!
        world = current_user.owned_worlds.build
        render Views::Worlds::New.new(world:)
      end
    end
  end

  # GET /worlds/:id/edit
  def edit
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world)
        render Views::Worlds::Edit.new(world:)
      end
    end
  end

  # POST /worlds
  def create
    respond_to do |format|
      format.html do
        current_user = Current.user!
        world_params = params.expect(world: [ :name, :blurb, :icon ])
        world = current_user.owned_worlds.build(**world_params)
        if world.save
          redirect_to(world)
        else
          render Views::Worlds::New.new(world:), status: :unprocessable_content
        end
      end
    end
  end

  # PUT /worlds/:id
  def update
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world)
        world_params = params.expect(world: [ :name, :blurb, :icon ])
        if world.update(**world_params)
          refresh_or_redirect_to(world)
        else
          render Views::Worlds::Edit.new(world:), status: :unprocessable_content
        end
      end
    end
  end

  # POST /worlds/:id/leave
  def leave
    current_user = Current.user!
    world = find_world
    authorize!(world)
    world.keys.accepted.where(recipient: current_user).destroy_all
    recede_or_redirect_to(home_path)
  end

  # DELETE /worlds/:id
  def destroy
    raise NotImplementedError
  end

  private

  # == Helpers ==

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:id))
  end
end
