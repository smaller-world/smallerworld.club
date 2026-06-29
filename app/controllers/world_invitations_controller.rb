# typed: true
# frozen_string_literal: true

class WorldInvitationsController < ApplicationController
  # == Configuration ==

  # allow_unauthenticated_access only: [ :create ]
  # skip_verify_authorized only: [ :create ]

  # == Actions ==

  # POST /world/:world_id/invitations
  # def create
  #   respond_to do |format|
  #     format.html do
  #       invitation_params = params.expect(invitation: [ :grant ])
  #     end
  #   end
  # end

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
