# typed: true
# frozen_string_literal: true

class HomeController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  skip_verify_authorized

  # == Filters ==

  before_action :redirect_to_appstore_if_app_required,
    only: :show,
    unless: :hotwire_native_app?

  # == Actions ==

  # GET /home?require_app=1&pass_serial_numbers[]=...
  def show
    respond_to do |format|
      format.html do
        if (current_user = Current.user)
          world_cards_pending_key_creation = if (pass_serial_numbers = params[:pass_serial_numbers])
            current_user
              .world_cards_pending_key_creation(pass_serial_numbers:)
              .includes(:world)
          end
          render Views::Home::Show.new(
            current_user:,
            world_cards_pending_key_creation:,
          )
        else
          redirect_to(new_session_path)
        end
      end
    end
  end

  private

  # == Helpers ==

  # TODO: Auto-link cards with existing keys?
  # sig do
  #   params(
  #     cards: WorldCard::PrivateRelation,
  #     current_user: User,
  #     current_device: Device,
  #   ).void
  # end
  # def autolink_cards(cards, current_user:, current_device:)
  #   cards.find_each do |card|
  #   end
  # end

  # == Callbacks ==

  sig { void }
  def redirect_to_appstore_if_app_required
    if params[:require_app].present?
      redirect_to(appstore_listing_path)
    end
  end
end
