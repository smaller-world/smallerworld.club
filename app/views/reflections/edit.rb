# typed: strict
# frozen_string_literal: true

class Views::Reflections::Edit < Views::Base
  include Phlex::Rails::Helpers::L

  # == Initialization ==

  sig { params(reflection: Reflection).void }
  def initialize(reflection:)
    super()
    @reflection = reflection
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      page_title: (localized_date unless hotwire_native_app?),
    ) do |app_layout|
      app_layout.with_navigation do
        button_back_to("the dock", places_dock_path, variant: :secondary)
      end

      app_layout.page_container do
        Components::ReflectionForm(reflection: @reflection)
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def localized_date
    l(@reflection.date, format: :long).downcase
  end
end
