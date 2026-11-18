# typed: strict
# frozen_string_literal: true

class Views::Reflections::Index < Views::Base
  # == Initialization ==

  sig do
    params(
      current_user: User,
      reflections: T::Array[Reflection],
      time_zone: ActiveSupport::TimeZone,
    ).void
  end
  def initialize(current_user:, reflections:, time_zone:)
    super()
    @current_user = current_user
    @reflections = reflections
    @time_zone = time_zone
  end

  # == View ==

  sig { override.void }
  def view_template
    turbo_frame_tag(:reflections) do
      Components::ItemGroup() do |item_group|
        @reflections.each do |reflection|
          Components::ReflectionItem(reflection:, time_zone: @time_zone)
        end
      end

      turbo_stream_from(@current_user, :reflections)
    end
  end
end
