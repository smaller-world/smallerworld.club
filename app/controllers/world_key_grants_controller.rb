# typed: true
# frozen_string_literal: true

class WorldKeyGrantsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: [ :show ]
  skip_verify_authorized only: [ :show, :accept ]

  # == Actions ==

  # GET /world_key_grants/:grant
  def show
    grant = params.fetch(:grant)
    WorldKey.verify_grant(grant) => { world_id:, color: }
    world = World.find(world_id)
    if (recipient = Current.user) && recipient.world_keys.exists?(world:, color:)
      redirect_to(world)
    elsif ios_browser? && !hotwire_native_app?
      card = world.cards.create!(granted_key_color: color)
      redirect_to(card)
    else
      render Views::WorldKeyGrants::Show.new(world:, grant:)
    end
  end

  # GET /worlds/:world_id/key_grants/new
  def new
    world = find_world
    authorize!(world, to: :manage?)
    key_color = params[:key_color]&.to_sym
    render Views::WorldKeyGrants::New.new(world:, key_color:)
  end

  # POST /world_key_grants/:grant/accept
  def accept
    respond_to do |format|
      format.html do
        current_user = Current.user!
        grant = params.fetch(:grant)
        WorldKey.verify_grant(grant) => { world_id:, color: }
        world = World.find(world_id)
        key = current_user.world_keys.build(
          world:,
          color:,
          accepted_at: Time.current,
        )
        if key.save
          redirect_to([ world, celebrate: true ], status: :see_other)
        else
          message = "failed to accept key"
          if (error = key.errors.full_messages.first)
            message = "#{message}: #{error}"
          end
          flash.now.alert = message
          render(
            Views::WorldKeyGrants::Show.new(world:, grant:),
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(scope: T.untyped).returns(World) }
  def find_world(scope: World.all)
    scope.friendly.find(params.fetch(:world_id))
  end
end
