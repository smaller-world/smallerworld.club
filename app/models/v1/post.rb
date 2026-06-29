# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: posts
#
#  id               :uuid             not null, primary key
#  body_html        :text
#  emoji            :string
#  hidden_from_ids  :uuid             default([]), not null, is an Array
#  images_ids       :uuid             default([]), not null, is an Array
#  pen_name         :string
#  pinned_until     :timestamptz
#  secret_location  :geography        point, 4326
#  title            :string
#  type             :string           not null
#  visibility       :string           not null
#  visible_to_ids   :uuid             default([]), not null, is an Array
#  created_at       :timestamptz      not null
#  updated_at       :timestamptz      not null
#  author_id        :uuid             not null
#  encouragement_id :uuid
#  prompt_id        :string
#  quoted_post_id   :uuid
#  space_id         :uuid
#  spotify_track_id :string
#  world_id         :uuid
#
# Indexes
#
#  index_posts_for_search                   ((((to_tsvector('simple'::regconfig, COALESCE((emoji)::text, ''::text)) || to_tsvector('simple'::regconfig, COALESCE((title)::text, ''::text))) || to_tsvector('simple'::regconfig, COALESCE(body_html, ''::text))))) USING gin
#  index_posts_on_author_id                 (author_id)
#  index_posts_on_author_id_and_created_at  (author_id,created_at)
#  index_posts_on_encouragement_id          (encouragement_id) UNIQUE
#  index_posts_on_hidden_from_ids           (hidden_from_ids) USING gin
#  index_posts_on_pinned_until              (pinned_until)
#  index_posts_on_prompt_id                 (prompt_id)
#  index_posts_on_quoted_post_id            (quoted_post_id)
#  index_posts_on_space_id                  (space_id)
#  index_posts_on_type                      (type)
#  index_posts_on_visibility                (visibility)
#  index_posts_on_visible_to_ids            (visible_to_ids) USING gin
#  index_posts_on_world_id                  (world_id)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (encouragement_id => encouragements.id)
#  fk_rails_...  (quoted_post_id => posts.id)
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
module V1
  class Post < ApplicationRecord
    # == Configuration ==

    V1_POST_TYPE_TO_TYPE_LABEL = T.let(
      {
        "journal_entry" => "journal entry",
        "poem" => "poem",
        "invitation" => "invitation",
        "question" => "ask",
        "follow_up" => "journal entry",
      }.freeze,
      T::Hash[String, String],
    )

    self.table_name = "posts"
    self.inheritance_column = nil

    sig { returns(String) }
    def self.polymorphic_name = "Post"

    # == Associations ==

    belongs_to :author, class_name: "V1::User", inverse_of: :posts
    has_one :rich_text_body,
      -> { where(name: "body") },
      class_name: "V1::ActionText::RichText",
      as: :record,
      inverse_of: :record,
      dependent: :destroy

    # Hand-rolled equivalent of `has_many_attached :images`, routed through
    # our V1-namespaced ActiveStorage classes.
    has_many :images_attachments,
      -> { where(name: "images") },
      class_name: "V1::ActiveStorage::Attachment",
      as: :record,
      inverse_of: :record,
      dependent: :destroy
    has_many :images_blobs,
      through: :images_attachments,
      class_name: "V1::ActiveStorage::Blob",
      source: :blob

    # == Methods ==

    sig { params(world: ::World).returns(TrueClass) }
    def import_to!(world)
      post_type = post_type_on!(world)
      post = ::Post.find_or_initialize_by(id:, type: post_type)
      images = import_ordered_images
      post.transaction do
        post.update_from_v1_post!(self, images:)
        world.update!(last_imported_v1_post_created_at: created_at)
      end
    end

    sig do
      type_parameters(:U).params(
        block: T.proc.params(files: T::Array[File]).returns(T.type_parameter(:U)),
      ).returns(T.type_parameter(:U))
    end
    def open_ordered_images(&block)
      Dir.mktmpdir("v1-images-") do |tmpdir|
        files = T.let([], T::Array[File])
        begin
          download_futures = T.let([], T::Array[Concurrent::Promise])
          ordered_image_blobs.each do |blob|
            file = File.open(File.join(tmpdir, blob.filename.to_s), "wb+") # rubocop:disable Style/FileOpen
            files << file
            download_futures << Concurrent::Promises.future do
              download_blob_to_file(blob, file)
            end
          end
          Concurrent::Promises.zip(*T.unsafe(download_futures)).value!
          yield files
        ensure
          files.each(&:close)
        end
      end
    end

    sig { returns(T::Array[::ActiveStorage::Blob]) }
    def import_ordered_images
      open_ordered_images do |files|
        promises = files.map do |file|
          Concurrent::Promises.future do
            ::ActiveStorage::Blob.create_and_upload!(
              io: file,
              filename: File.basename(file.to_path),
            )
          end
        end
        Concurrent::Promises.zip(*T.unsafe(promises)).value!
      end
    end

    sig { override.returns(String) }
    def body_html
      if (rich_text_body = public_send(:rich_text_body))
        rich_text_body.body.to_html
      else
        tiptap_html = T.must(super)
        convert_tiptap_html(tiptap_html)
      end
    end

    private

    # == Helpers ==

    sig { params(html: String).returns(String) }
    def convert_tiptap_html(html)
      fragment = Nokogiri::HTML5.fragment(html)

      # Lexxy list items hold inline content with a 1-based `value` attribute,
      # whereas TipTap wraps each item's content in a <p>.
      fragment.css("ul, ol").each do |list|
        index = 0
        list.css("> li").each do |item|
          index += 1
          item.css("> p").each { |paragraph| paragraph.replace(paragraph.children) }
          item["value"] = index.to_s
        end
      end

      # Empty paragraphs become <p><br></p> in Lexxy.
      fragment.css("p").each do |paragraph|
        next unless paragraph.text.strip.empty? &&
          paragraph.css("img, br, hr").empty?

        paragraph.children.unlink
        paragraph << Nokogiri::XML::Node.new("br", paragraph.document)
      end

      fragment.to_html
    end

    sig { returns(T::Array[V1::ActiveStorage::Blob]) }
    def ordered_image_blobs
      attachments = images_attachments.to_a
      attachments_by_blob_id = attachments.index_by(&:blob_id)
      images_ids.filter_map { |blob_id| attachments_by_blob_id[blob_id]&.blob }
    end

    sig { params(blob: V1::ActiveStorage::Blob, file: File).void }
    def download_blob_to_file(blob, file)
      file.binmode
      blob.download do |chunk|
        file.write(chunk)
      end
      file.flush
      file.rewind
    end

    sig { params(world: World).returns(PostType) }
    def post_type_on!(world)
      label = V1_POST_TYPE_TO_TYPE_LABEL.fetch(type)
      world.post_types.find_by!(label:)
    end
  end
end
