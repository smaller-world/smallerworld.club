# typed: true
# frozen_string_literal: true

class SpacesController < ApplicationController
  # == Configuration ==

  POSTS_PER_PAGE = 5

  # == Filters ==

  before_action :redirect_to_canonical_address, only: %i[show edit]

  # == Actions ==

  # GET /spaces
  def index
    respond_to do |format|
      format.html do
        @page_title = "spaces" unless hotwire_native_app?
        current_user = authenticate_user!
        @owned_spaces = current_user.owned_spaces.with_attached_icon
        @posted_spaces = current_user.posted_spaces
          .where.not(id: @owned_spaces.select(:id))
          .with_attached_icon
      end
    end
  end

  # GET /spaces/new
  def new
    respond_to do |format|
      format.html do
        @page_title = "new space"
        @space = Space.new
      end
    end
  end

  # GET /spaces/:id
  def show
    respond_to do |format|
      format.html do
        if hotwire_native_app?
          @space = find_space(scope: Space.with_attached_icon)
          # @page_title = @space.name
          @pagy, @posts = scoped do
            scope = @space.posts
              .order(created_at: :desc, id: :asc)
              .with_author_world
              .with_attached_images
              .with_quoted_post_and_attached_images
            pagy(:keyset, scope, limit: POSTS_PER_PAGE)
          end
        else
          space = find_space(scope: Space.with_attached_icon)
          user_world = current_user&.world
          render(inertia: "SpacePage", world_theme: "cloudflow", props: {
            space: SpaceSerializer.one(space),
            "userWorld" => WorldSerializer.one_if(user_world)
          })
        end
      end
    end
  end

  # GET /spaces/:id/edit
  def edit
    respond_to do |format|
      format.html do
        @page_title = "edit space"
        @space = find_space(scope: Space.with_attached_icon)
      end
    end
  end

  # POST /spaces
  def create
    respond_to do |format|
      format.html do
        current_user = authenticate_user!
        space_params = params.expect(space: permitted_space_attributes)
        @space = current_user.owned_spaces.build(**space_params)
        if @space.save
          redirect_to(space_path(@space), status: :see_other)
        else
          render :new, status: :unprocessable_content
        end
      end
    end
  end

  # PUT/PATCH /spaces/:id
  def update
    respond_to do |format|
      format.html do
        @space = find_space(scope: Space.with_attached_icon)
        authorize!(@space)
        space_params = params.expect(space: permitted_space_attributes)
        if @space.update(space_params)
          refresh_or_redirect_to(
            space_path(@space, emulate_native_app: 1),
            status: :see_other,
          )
        else
          render :edit, status: :unprocessable_content
        end
      end
    end
  end


  private

  # == Filter handlers

  sig { void }
  def redirect_to_canonical_address
    space = find_space(scope: Space.select(:id, :name))
    if space_id != space.friendly_id
      redirect_to(polymorphic_path(space, action: action_name), status: :found)
    end
  end

  sig { returns(String) }
  def space_id
    params.fetch(:id)
  end

  sig { params(scope: Space::PrivateRelation).returns(Space) }
  def find_space(scope: Space.all)
    scope.friendly.find(space_id)
  end

  sig { returns(T::Array[Symbol]) }
  def permitted_space_attributes
    allowed_attributes = %i[name description icon]
    if current_user&.admin?
      allowed_attributes << :public
    end
    allowed_attributes
  end
end
