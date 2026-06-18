# typed: strict
# frozen_string_literal: true

class Components::PostCardSkeleton < Components::Base
  # == Component ==

  sig { override.void }
  def view_template
    Components::Card(size: :sm, **mix({ class: "post-card" }, @attributes)) do |card|
      card.header do
        card.description do
          span(class: "skeleton") do
            "timestamp"
          end
        end
        card.title do
          span(class: "skeleton") do
            "post title placeholder"
          end
        end
      end
      card.content(class: "flex flex-col gap-4") do
        2.times do
          p(class: "skeleton h-24")
        end
      end
      card.footer(class: "flex justify-center") do
        Components::Button(class: "skeleton") do
          "placeholder"
        end
      end
    end
  end
end
