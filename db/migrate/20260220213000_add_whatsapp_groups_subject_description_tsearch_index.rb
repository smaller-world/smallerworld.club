class AddWhatsappGroupsSubjectDescriptionTsearchIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :whatsapp_groups,
              <<~SQL.squish,
                (
                  setweight(to_tsvector('simple', coalesce(subject, '')), 'A') ||
                  setweight(to_tsvector('simple', coalesce(description, '')), 'B')
                )
              SQL
              using: :gin,
              name: "index_whatsapp_groups_on_subject_description_tsearch",
              algorithm: :concurrently
  end
end
