# typed: true
# frozen_string_literal: true

class SupportRequestsController < PublicController
  # == Actions ==

  # GET /support
  def new
    render Views::SupportRequests::New.new
  end
end
