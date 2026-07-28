# typed: true
# frozen_string_literal: true

class WorldKeyGrantsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: [ :show, :accept ]
  skip_verify_authorized only: [ :show, :accept ]

  # == Actions ==

  # GET /world_key_grants/:message
  def show
    verified_grant = verify_grant_message
    world = verified_grant.world
    if (recipient = Current.user) && recipient.world_keys.exists?(world:)
      redirect_to(world)
    else
      render Views::WorldKeyGrants::Show.new(verified_grant:)
    end
  end

  # GET /worlds/:world_id/key_grants/new?granted_post_type_ids=...
  def new
    world = find_world
    authorize!(world, to: :manage?)
    grant = WorldKeyGrant.new(params.permit(granted_post_type_ids: []), world:)
    render Views::WorldKeyGrants::New.new(grant:)
  end

  # POST /world_key_grants/:message/accept
  def accept
    respond_to do |format|
      format.turbo_stream do
        verified_grant = verify_grant_message
        if (current_user = Current.user)
          accept_world_key(current_user:, verified_grant:)
        else
          accept_world_invitation(verified_grant:)
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

  sig { returns(VerifiedWorldKeyGrant) }
  def verify_grant_message
    WorldKey.verify_grant(params.fetch(:message))
  end

  sig { params(current_user: User, verified_grant: VerifiedWorldKeyGrant).void }
  def accept_world_key(current_user:, verified_grant:)
    world = verified_grant.world
    world_key = current_user.world_keys.build(
      world:,
      granted_post_type_ids: verified_grant.post_type_ids,
    )
    if world_key.save
      flash[:celebrate] = true
      redirect_to(world, status: :see_other)
    else
      message = "failed to create world key"
      if (error = world_key.errors.full_messages.first)
        message = "#{message}: #{error}"
      end
      render(
        turbo_stream: turbo_stream.update(
          "flashes",
          renderable: Components::AppFlashAlert.new(message:, type: :alert),
        ),
        status: :unprocessable_content,
      )
    end
  end

  sig { params(verified_grant: VerifiedWorldKeyGrant).void }
  def accept_world_invitation(verified_grant:)
    world = verified_grant.world
    world_invitation_params = params.expect(
      world_invitation: [ :recipient_phone_number ],
    )
    recipient_phone_number = WorldInvitation.normalize_value_for(
      :recipient_phone_number,
      world_invitation_params.fetch(:recipient_phone_number),
    )
    world_invitation = world.invitations
      .find_or_initialize_by(recipient_phone_number:)
    if world_invitation.update(granted_post_type_ids: verified_grant.post_type_ids)
      if hotwire_native_app?
        resume_or_redirect_to(
          new_session_path(phone_number: recipient_phone_number),
          status: :see_other,
        )
      else
        redirect_to(installation_instructions_path)
      end
    else
      render(
        turbo_stream: turbo_stream.replace(
          "accept_world_key_grant_form",
          renderable: Components::AcceptWorldKeyGrantForm.new(
            verified_grant:,
            invitation: world_invitation,
          ),
        ),
        status: :unprocessable_content,
      )
    end
  end
end
