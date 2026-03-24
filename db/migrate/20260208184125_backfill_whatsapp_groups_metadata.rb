# typed: true
# frozen_string_literal: true

class BackfillWhatsappGroupsMetadata < ActiveRecord::Migration[8.1]
  def up
    groups = WhatsappGroup.all.to_a
    return if groups.empty?

    if (first_group = groups.first)
      first_group.import_metadata
    end
    groups.drop(1).each(&:import_metadata_later)
  end
end
