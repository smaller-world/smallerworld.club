# typed: true
# frozen_string_literal: true

class UiDocsController < ApplicationController
  # == Filters ==

  allow_unauthenticated_access

  # == Actions ==

  # GET /ui
  def index
    render Views::UiDocs::Index
  end

  # GET /ui/:component
  def show
    component = params.fetch(:component)
    case component
    when "alerts"
      render Views::UiDocs::Alerts
    else
      redirect_to(ui_docs_path, alert: "no docs for: #{component}")
    end
  end
end
