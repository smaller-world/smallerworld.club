# typed: true
# frozen_string_literal: true

class PostTypesController < ApplicationController
  # == Actions ==

  # GET /worlds/:world_id/post_types/new
  def new
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :manage?)
        post_type = world.post_types.build
        render Views::PostTypes::New.new(post_type:)
      end
    end
  end

  # GET /post_types/:id/edit[?return_to=...]
  def edit
    respond_to do |format|
      format.html do
        post_type = find_post_type
        authorize!(post_type)
        return_url = if (url = params[:return_to]) && url.is_a?(String)
          url
        end
        render Views::PostTypes::Edit.new(post_type:, return_url:)
      end
    end
  end

  # POST /worlds/:world_id/post_types
  def create
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :manage?)
        post_type_params = params.expect(
          post_type: [ :name, :icon ],
        )
        post_type = world.post_types.build(**post_type_params)
        if post_type.save
          refresh_or_redirect_to(
            [ :new, world, :post, type_id: post_type.id ],
            status: :see_other,
          )
        else
          render Views::PostTypes::New.new(post_type:), status: :unprocessable_content
        end
      end
    end
  end

  # PUT/PATCH /post_types/:id
  def update
    respond_to do |format|
      format.html do
        post_type = find_post_type
        authorize!(post_type)
        return_url = if (url = params[:return_url]) && url.is_a?(String)
          url
        end
        post_type_params = params.expect(
          post_type: [ :name, :icon ],
        )
        if post_type.update(**post_type_params)
          redirect_to(return_url || [ post_type.world, new_post: 1 ], status: :see_other)
        else
          render Views::PostTypes::Edit.new(post_type:, return_url:), status: :unprocessable_content
        end
      end
    end
  end

  # DELETE /post_types/:id
  def destroy
    respond_to do |format|
      format.html do
        post_type = find_post_type
        authorize!(post_type)
        if post_type.destroy
          refresh_or_redirect_to([ post_type.world, new_post: 1 ])
        else
          message = "failed to delete post type"
          if (error = post_type.errors.full_messages.first)
            message = "#{message}: #{error}"
          end
          flash.now[:alert] = message
          render Views::PostTypes::Edit.new(post_type:, return_url: nil),
            status: :unprocessable_content
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(PostType) }
  def find_post_type
    PostType.find(params.fetch(:id))
  end

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:world_id))
  end
end
