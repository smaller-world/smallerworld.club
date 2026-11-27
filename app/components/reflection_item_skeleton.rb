# typed: strict
# frozen_string_literal: true

class Components::ReflectionItemSkeleton < Components::Base
  # == Component ==

  sig { override.void }
  def view_template
    Components::Item(
      variant: :outline,
      size: :xs,
      **mix({ class: "rounded-none" }, @attributes),
    ) do |item|
      item.content do |item_content|
        item_content.title do
          span(class: "skeleton") do
            "date"
          end
        end
        item_content.description do
          span(class: "skeleton") do
            "placeholder"
          end
        end
      end
    end
  end
end
