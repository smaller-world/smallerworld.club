# typed: true
# frozen_string_literal: true

class WorldKeyGrantsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: [ :show, :accept ]
  skip_verify_authorized only: [ :show, :accept ]

  # == Actions ==

  # GET /world_invitations/:grant?linked_card_id=...
  def show
    grant = params.fetch(:grant)
    WorldKey.verify_grant(grant) => { world_id:, color: }
    world = World.find(world_id)
    if (recipient = Current.user) && recipient.world_keys.exists?(world:, color:)
      redirect_to(world)
    elsif hotwire_native_app? || !ios_browser?
      key = world.keys.build(color:, recipient: Current.user)
      card = if (card_id = params[:card_id])
        card = WorldCard.find(card_id)
        card if card.world_id == world_id && card.active? && card.unlinked?
      end
      render Views::WorldKeyGrants::Show.new(key:, card:)
    else
      card = world.cards.create!(granted_key_color: color)
      redirect_to(card)
    end
  end

  # GET /worlds/:world_id/key_grants/new
  def new
    world = find_world
    authorize!(world, to: :manage?)
    key_color = params[:key_color]&.to_sym
    render Views::WorldKeyGrants::New.new(world:, key_color:)
  end

  # POST /world_invitations/:grant/accept
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
          if (card_id = params[:linked_card_id])
            card = WorldCard.find(card_id)
            if card.world_id == world_id && card.active? && card.unlinked?
              link_card(card)
            end
          end
          redirect_to([ world, celebrate: true ])
        else
          flash.now.alert = key.errors.full_messages.first
          render(
            Views::WorldKeyGrants::Show.new(key:),
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:world_id))
  end

  def ios_browser?
    client = DeviceDetector.new(request.user_agent, request.headers.to_h)
    client.os_family == "iOS"
  end

  sig { params(card: WorldCard).void }
  def link_card(card)
    unless card.update(cardholder: Current.user!, device: Current.device!)
      message = "Failed to link card"
      if (error = card.errors.full_messages.first)
        message = "#{message}: #{error}"
      end
      Sentry.capture_message(message)
      tag_logger do
        logger.error(message)
      end
    end
  end
end
