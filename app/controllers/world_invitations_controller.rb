# typed: true
# frozen_string_literal: true

class WorldInvitationsController < ApplicationController
  # == Configuration ==

  # allow_unauthenticated_access only: [ :create ]
  # skip_verify_authorized only: [ :create ]

  # == Actions ==

  # GET /invitations/:id
  def show
    respond_to do |format|
      format.html do
        invitation = find_invitation(scope: WorldInvitation.pending_acceptance)
        authorize!(invitation)
        redirect_to(world_key_grant_path(grant: invitation.world_key_grant))
      end
    end
  end

  # GET /world/:world_id/invitations/new?recipient_id=...
  def new
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :manage?)
        recipient_id = params.fetch(:recipient_id)
        recipient = User.find(recipient_id)
        invitation = world.invitations.build(recipient:)
        render Views::WorldInvitations::New.new(invitation:)
      end
    end
  end

  # POST /world/:world_id/invitations
  def create
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :manage?)
        invitation_params = params.expect(
          world_invitation: [ :recipient_id, granted_post_type_ids: [] ],
        )
        invitation = world.invitations.build(**invitation_params)
        if invitation.save
          refresh_or_redirect_to([ world, :keys ], status: :see_other)
        else
          redirect_to(
            [ world, :keys ],
            alert: "failed to send invitation",
            status: :see_other,
          )
        end
      end
    end
  end

  # DELETE /world/:world_id/invitations
  def destroy
    respond_to do |format|
      format.html do
        invitation = find_invitation
        authorize!(invitation)
        world = invitation.world!
        invitation.destroy!
        refresh_or_redirect_to([ world, :keys ], status: :see_other)
      end
    end
  end

  private

  # == Helpers ==

  sig { params(scope: WorldInvitation::PrivateRelation).returns(WorldInvitation) }
  def find_invitation(scope: WorldInvitation.all)
    scope.find(params.fetch(:id))
  end

  sig { params(scope: T.untyped).returns(World) }
  def find_world(scope: World.all)
    scope.friendly.find(params.fetch(:world_id))
  end
end
