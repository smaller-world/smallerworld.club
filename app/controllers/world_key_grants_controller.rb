# typed: true
# frozen_string_literal: true

class WorldKeyGrantsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: [ :show, :accept ]
  skip_verify_authorized only: [ :show, :accept ]

  # == Actions ==

  # GET /world_key_grants/:grant
  def show
    grant = params.fetch(:grant)
    grant_message = WorldKey.verify_grant(grant)
    world = World.find(grant_message.world_id)
    if (recipient = Current.user) && recipient.world_keys.exists?(world:)
      redirect_to(world)
    else
      render Views::WorldKeyGrants::Show.new(world:, grant:)
    end
  end

  # GET /worlds/:world_id/key_grants/new?granted_post_type_ids=...
  def new
    world = find_world
    authorize!(world, to: :manage?)
    granted_post_types = if (post_type_ids = params[:granted_post_type_ids])
      PostType.where(id: post_type_ids).to_a
    else
      []
    end
    render Views::WorldKeyGrants::New.new(world:, granted_post_types:)
  end

  # POST /world_key_grants/:grant/accept
  def accept
    respond_to do |format|
      format.turbo_stream do
        grant = params.fetch(:grant)
        grant_message = WorldKey.verify_grant(grant)
        world = World.find(grant_message.world_id)
        if (current_user = Current.user)
          accept_world_key(current_user:, world:, grant:, grant_message:)
        else
          accept_world_invitation(world:, grant:, grant_message:)
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

  sig do
    params(
      current_user: User,
      world: World,
      grant: String,
      grant_message: WorldKey::GrantMessage,
    ).void
  end
  def accept_world_key(current_user:, world:, grant:, grant_message:)
    world_key = current_user.world_keys.build(
      world:,
      granted_post_type_ids: grant_message.post_type_ids,
    )
    if world_key.save
      redirect_to([ world, celebrate: true ], status: :see_other)
    else
      message = "failed to create world key"
      if (error = world_key.errors.full_messages.first)
        message = "#{message}: #{error}"
      end
      render(
        turbo_stream: turbo_stream.update(
          :flash,
          renderable: Components::AppFlashAlert.new(message:, type: :alert),
        ),
        status: :unprocessable_content,
      )
    end
  end

  sig do
    params(
      world: World,
      grant: String,
      grant_message: WorldKey::GrantMessage,
    ).void
  end
  def accept_world_invitation(world:, grant:, grant_message:)
    world_invitation_params = params.expect(
      world_invitation: [ :recipient_phone_number ],
    )
    recipient_phone_number = WorldInvitation.normalize_value_for(
      :recipient_phone_number,
      world_invitation_params.fetch(:recipient_phone_number),
    )
    world_invitation = world.invitations
      .find_or_initialize_by(recipient_phone_number:)
    world_invitation.update(granted_post_type_ids: grant_message.post_type_ids)
    if world_invitation.valid? && hotwire_native_app?
      resume_or_redirect_to(
        new_session_path(phone_number: recipient_phone_number),
        status: :see_other,
      )
    else
      render(
        turbo_stream: turbo_stream.replace(
          :accept_world_key_grant_form,
          renderable: Components::AcceptWorldKeyGrantForm.new(
            world:,
            grant:,
            invitation: world_invitation,
          ),
        ),
        status: world_invitation.valid? ? :ok : :unprocessable_content,
      )
    end
  end
end
