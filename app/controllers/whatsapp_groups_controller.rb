# typed: true
# frozen_string_literal: true

class WhatsappGroupsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: :message_history

  # == Actions ==

  # GET /groups/:id/message_history
  def message_history
    respond_to do |format|
      format.html do
        group = find_group
        # messages_scope = group.messages.order(created_at: :desc)
        # pagy, messages = pagy(:countish, messages_scope)
        render Views::WhatsappGroups::MessageHistory.new(
          group:,
          # messages:,
          # pagy:,
        )
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(WhatsappGroup) }
  def find_group
    WhatsappGroup.friendly.find(params.fetch(:id))
  end
end
