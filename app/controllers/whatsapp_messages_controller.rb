# typed: true
# frozen_string_literal: true

class WhatsappMessagesController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: :index

  # == Actions =

  # GET /groups/:whatsapp_group_id/messages
  def index
    respond_to do |format|
      format.turbo_stream do
        group = find_group
        pagy, messages = pagy(:countless, group.messages.reverse_chronological)

        update_pagination = if pagy.next
          turbo_stream.replace(
            "pagination",
            renderable: Components::Chat::PaginationButton.new(
              group:,
              pagy:,
              disable_for: 1.second,
            ),
          )
        else
          turbo_stream.remove("pagination")
        end
        prepend_messages = turbo_stream.prepend(
          "messages",
          renderable: Components::Chat::Messages.new(messages: messages.reverse),
        )

        render turbo_stream: [ update_pagination, prepend_messages ]
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(WhatsappGroup) }
  def find_group
    WhatsappGroup.friendly.find(params.fetch(:whatsapp_group_id))
  end
end
