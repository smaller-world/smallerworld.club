# typed: true
# frozen_string_literal: true

class ReflectionsController < ApplicationController
  # == Configuration ==

  skip_verify_authorized only: :index

  # == Actions ==

  # GET /reflections?time_zone_name=...
  def index
    respond_to do |format|
      if turbo_frame_request?
        format.html do
          current_user = Current.user!
          time_zone = parse_time_zone
          reflections = recent_reflections(time_zone:)
          render Views::Reflections::Index.new(current_user:, reflections:, time_zone:)
        end
      end
    end
  end

  # GET /reflections/:date/edit
  def edit
    respond_to do |format|
      format.html do
        reflection = find_reflection
        authorize!(reflection)
        render Views::Reflections::Edit.new(reflection:)
      end
    end
  end

  # PUT/PATCH /reflections/:date
  def update
    respond_to do |format|
      format.html do
        reflection = find_reflection
        authorize!(reflection)
        reflection_params = params.expect(reflection: [ :emoji, :body ])
        if reflection.update(**reflection_params)
          resume_or_redirect_to([ :places, :dock ])
        else
          render Views::Reflections::Edit.new(reflection:), status: :unprocessable_content
        end
      end
    end
  end

  private

  # == Helpers ==

  sig do
    params(time_zone: ActiveSupport::TimeZone).returns(T::Array[Reflection])
  end
  def recent_reflections(time_zone:)
    current_user = Current.user!
    now = time_zone.now
    today = now.to_date
    latest_date = now.hour < 12 ? today - 1 : today
    dates = latest_date.downto(latest_date - 6).to_a
    existing = authorized_scope(current_user.reflections)
      .where(date: dates)
      .with_rich_text_body
      .index_by(&:date)

    dates.map do |date|
      existing[date] || current_user.reflections.build(date: date)
    end
  end

  sig { returns(Date) }
  def parse_date
    date_iso8601 = params.fetch(:date)
    Date.iso8601(date_iso8601)
  end

  sig { returns(ActiveSupport::TimeZone) }
  def parse_time_zone
    time_zone_name = params[:time_zone_name]
    time_zone = ActiveSupport::TimeZone[time_zone_name] if time_zone_name.is_a?(String)
    time_zone or raise ActionController::BadRequest, "Invalid time zone"
  end

  sig { returns(Reflection) }
  def find_reflection
    current_user = Current.user!
    date = parse_date
    current_user.reflections.find_or_initialize_by(date:)
  rescue Date::Error
    raise ActiveRecord::RecordNotFound, "Invalid date"
  end
end
