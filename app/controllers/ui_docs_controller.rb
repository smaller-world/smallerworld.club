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
    component_class = component.pluralize.camelize
    begin
      render Views::UiDocs.const_get(component_class.to_sym) # rubocop:disable Sorbet/ConstantsFromStrings
    rescue NameError
      redirect_to(ui_docs_path, alert: "No doc for component: #{component_class}")
    end
  end
end
