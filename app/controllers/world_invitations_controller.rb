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
        redirect_to(world_key_grant_path(message: invitation.world_key_grant_message))
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

  # GET /invitations/:id/edit
  def edit
    respond_to do |format|
      format.html do
        invitation = find_invitation
        authorize!(invitation)
        render Views::WorldInvitations::Edit.new(invitation:)
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
          render(
            Views::WorldInvitations::New.new(invitation:),
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  # PUT/PATCH /world/:world_id/invitations
  def update
    respond_to do |format|
      format.html do
        invitation = find_invitation
        authorize!(invitation)
        invitation_params = params.expect(world_invitation: [ granted_post_type_ids: [] ])
        if invitation.update(**invitation_params)
          refresh_or_redirect_to([ invitation.world, :keys ], status: :see_other)
        else
          render(
            Views::WorldInvitations::Edit.new(invitation:),
            status: :unprocessable_content,
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
