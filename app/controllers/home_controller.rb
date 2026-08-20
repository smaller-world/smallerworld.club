# typed: true
# frozen_string_literal: true

class HomeController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  skip_verify_authorized

  # == Actions ==

  # GET /home[?user_reported=1]
  def show
    respond_to do |format|
      format.html do
        current_user = Current.user!
        if cast_boolean(params[:report_notice])
          flash.now[:notice] = "your report has been submitted and will be reviewed by our team."
        end
        render Views::Home::Show.new(current_user:)
      end
    end
  end

  # private

  # == Helpers ==

  # sig { returns(T::Boolean) }
  # def app_required?
  #   cast_boolean(params[:require_app])
  # end

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
end
