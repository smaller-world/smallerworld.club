# typed: true
# frozen_string_literal: true

module Admin
  class WebhookMessagesController < AdminController
    # GET /admin/webhook_logs
    def index
      respond_to do |format|
        format.html do
          messages_scope = WebhookMessage.order(timestamp: :desc)
          pagy, messages = pagy(:countish, messages_scope)
          render Views::Admin::WebhookMessages::Index.new(messages:, pagy:)
        end
      end
    end
  end
end
