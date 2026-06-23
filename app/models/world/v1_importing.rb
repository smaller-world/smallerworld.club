# typed: strict
# frozen_string_literal: true

module World::V1Importing
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { World }

  # == Methods ==

  sig { returns(V1::Post::PrivateRelation) }
  def v1_posts
    V1::Post.joins(:author)
      .where(author: { phone_number: owner_phone_number })
      .where.not(world_id: nil)
      .distinct
      .chronological
  end

  sig { returns(V1::Post::PrivateRelation) }
  def unimported_v1_posts
    scope = v1_posts
    if (created_at = last_imported_v1_post_created_at)
      scope.where!(V1::Post.arel_table[:created_at].gt(created_at))
    end
    scope
  end

  sig { returns(T::Boolean) }
  def has_importable_v1_posts?
    eldest_world? && unimported_v1_posts.any?
  end

  sig { returns(T.nilable(SolidQueue::Job)) }
  def current_v1_posts_import_job
    arguments_json = { "_aj_globalid" => to_gid }.to_json
    scope = SolidQueue::Job
      .where(class_name: "ImportV1PostsJob")
      .where("arguments LIKE ?", "%#{arguments_json}%")
    scope
      .where(id: SolidQueue::ReadyExecution.select(:job_id))
      .or(scope.where(id: SolidQueue::ClaimedExecution.select(:job_id)))
      .order(created_at: :desc)
      .first
  end

  sig { params(limit: T.nilable(Integer)).void }
  def import_v1_posts!(limit: nil)
    T.bind(self, World)

    scope = unimported_v1_posts
    if limit
      scope.limit!(limit)
    end
    scope.each do |post|
      post.import_to!(self)
      broadcast_v1_posts_import_progress
    end
  end

  sig { params(limit: T.nilable(Integer), options: T.untyped).returns(ImportV1PostsJob) }
  def import_v1_posts_later(limit: nil, **options)
    ImportV1PostsJob
      .set(**options)
      .perform_later(
        self,
        last_imported_post_created_at: last_imported_v1_post_created_at,
        limit:,
      )
  end

  sig { void }
  def reset_v1_posts_import!
    transaction do
      posts.with_v1_attributes.destroy_all
      update!(last_imported_v1_post_created_at: nil)
    end
  end

  sig { params(limit: Integer).void }
  def rollback_v1_post_import!(limit: 1)
    transaction do
      destroyed_posts = posts.with_v1_attributes
        .reverse_chronological.limit(limit)
        .destroy_all
      if destroyed_posts.any?
        update!(
          last_imported_v1_post_created_at:
            posts.with_v1_attributes.reverse_chronological.pick(:created_at),
        )
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def eldest_world?
    user = owner!
    user.owned_worlds.chronological.pick(:id) == id
  end

  sig { void }
  def broadcast_v1_posts_import_progress
    broadcast_action_to(
      self,
      :v1_posts_import,
      action: :reload,
      target: :v1_posts_import,
      render: false,
    )
  end
end
