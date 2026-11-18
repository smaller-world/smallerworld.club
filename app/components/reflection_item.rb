# typed: strict
# frozen_string_literal: true

class Components::ReflectionItem < Components::Base
  # == Initialization ==

  sig do
    params(
      reflection: Reflection,
      time_zone: ActiveSupport::TimeZone,
      attributes: T.untyped,
    ).void
  end
  def initialize(reflection:, time_zone:, **attributes)
    super(**attributes)
    @reflection = reflection
    @time_zone = time_zone

    @reflection_date = T.let(
      @reflection.date.in_time_zone(@time_zone),
      ActiveSupport::TimeWithZone,
    )
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Item(
      element: :a,
      href: edit_reflection_path(@reflection.date.iso8601),
      variant: :outline,
      size: :xs,
      **mix(
        {
          class: "reflection-item",
          data: {
            new: (true if @reflection.new_record?),
            today: (true if @reflection_date.today?),
          },
        },
        @attributes,
      ),
    ) do |item|
      item.content do |item_content|
        item_content.title(class: "w-auto justify-between") do
          span do
            if @reflection_date.today?
              plain("today, ")
            end
            local_date(@reflection_date, class: "font-heading lowercase")
          end
          if (emoji = @reflection.emoji)
            span(class: "font-emoji") do
              emoji
            end
          end
        end
        item_content.description(
          class: "text-xs whitespace-pre-line line-clamp-6 wrap-anywhere",
        ) do
          if @reflection.new_record?
            if @reflection_date.today?
              "reflect on your day!"
            else
              "click to add a reflection for this day"
            end
          else
            @reflection.plain_body
          end
        end
      end
    end
  end
end
