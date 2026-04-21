# typed: true
# frozen_string_literal: true

class WorldsController < ApplicationController
  # GET /worlds
  def index
    respond_to do |format|
      format.html do
        current_user = current_user!
        render Views::Worlds::Index.new(current_user:)
      end
    end
  end

  # GET /worlds/:id
  # GET /@:id
  def show
    world = find_world
    pagy, posts = pagy(
      :countless,
      world.posts.reverse_chronological,
      limit: 5,
    )
    respond_to do |format|
      format.html do
        render Views::Worlds::Show.new(world:, posts:, pagy:)
      end

      format.turbo_stream do
        append_posts = turbo_stream.append(
          :posts,
          renderable: Views::Worlds::Show::PostItems.new(posts:),
        )
        update_next_page_control = if pagy.next
          turbo_stream.replace(
            :next_page_control,
            renderable: Views::Worlds::Show::NextPageControl.new(
              world:,
              pagy:,
              disable_for: 1.second,
            ),
          )
        else
          turbo_stream.remove(:next_page_control)
        end
        render turbo_stream: [ append_posts, update_next_page_control ]
      end
    end
  end

  # GET /worlds/new
  def new
    respond_to do |format|
      format.html do
        current_user = current_user!
        world = current_user.worlds.build
        render Views::Worlds::New.new(world:)
      end
    end
  end

  # GET /worlds/:id/edit
  def edit
    respond_to do |format|
      format.html do
        world = find_world
        render Views::Worlds::Edit.new(world:)
      end
    end
  end

  # POST /worlds
  def create
    respond_to do |format|
      format.html do
        current_user = current_user!
        world_params = params.expect(world: [ :name, :icon ])
        world = current_user.worlds.build(**world_params)
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
        world_params = params.expect(world: [ :name, :icon ])
        if world.update(**world_params)
          redirect_to(world)
        else
          render Views::Worlds::Edit.new(world:), status: :unprocessable_content
        end
      end
    end
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
