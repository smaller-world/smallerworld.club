# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: reports
#
#  id              :uuid             not null, primary key
#  category        :string           not null
#  note            :text
#  reportable_type :string           not null
#  resolution      :string
#  resolved_at     :timestamptz
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  moderator_id    :uuid
#  reportable_id   :uuid             not null
#  reporter_id     :uuid             not null
#
# Indexes
#
#  index_reports_on_moderator_id  (moderator_id)
#  index_reports_on_reportable    (reportable_type,reportable_id)
#  index_reports_on_reporter_id   (reporter_id)
#  index_reports_on_resolution    (resolution)
#  index_reports_on_resolved_at   (resolved_at)
#
# Foreign Keys
#
#  fk_rails_...  (moderator_id => users.id)
#  fk_rails_...  (reporter_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Report < ApplicationRecord
  include NormalizesText

  # == Configuration ==

  REPORTABLE_TYPES = [ "Post", "User" ]

  # == Attributes ==

  enumerize :category, in: [
    :violence,
    :sexual_abuse,
    :fraud,
    :illegal_activity,
    :privacy_violation,
    :spam,
    :other,
  ]

  # An unresolved report has no resolution. Upholding keeps the reportable
  # hidden indefinitely; dismissing restores it.
  enumerize :resolution, in: [ :upheld, :dismissed ]

  sig { returns(T::Boolean) }
  def resolved? = resolved_at?

  sig { returns(Enumerize::Value) }
  def resolution!
    resolution or raise ApplicationError, "Unresolved report"
  end

  # == Associations ==

  belongs_to :reportable, polymorphic: true
  belongs_to :reporter, class_name: "User"
  belongs_to :moderator, class_name: "User", optional: true

  sig { returns(T.all(ActiveRecord::Base, Reportable)) }
  def reportable!
    reportable or raise ActiveRecord::RecordNotFound, "Missing reportable"
  end

  sig { returns(User) }
  def reporter!
    reporter or raise ActiveRecord::RecordNotFound, "Missing reporter"
  end

  # == Normalizations ==

  strips_text :note
  nilify_blanks :note

  # == Validations ==

  validates :note, presence: true, if: :note_required?
  validates :reportable_type, inclusion: { in: REPORTABLE_TYPES }
  validates :moderator, :resolution, presence: true, if: :resolved?

  # == Hooks ==

  after_create :trigger_reportable_callback
  after_create_commit :deliver_created_notification_later

  # == Scopes ==

  scope :unresolved, -> { where(resolved_at: nil) }
  scope :resolved, -> { where.not(resolved_at: nil) }
  scope :upheld, -> { where(resolution: "upheld") }
  scope :dismissed, -> { where(resolution: "dismissed") }

  # Reports that suppress their reportable: everything except those an admin
  # has explicitly dismissed. Unresolved reports suppress by default, so that
  # harmful content is hidden while it waits to be moderated.
  #
  # NOTE: Matches NULL explicitly. `where.not(resolution: "dismissed")` would
  # compile to `resolution != 'dismissed'`, which is NULL — and therefore
  # false — for unresolved reports.
  scope :not_dismissed, -> { where(resolution: [ nil, "upheld" ]) }

  # Pending reports, longest-waiting last (newest first).
  scope :pending_first, -> {
    order(Arel.sql("resolved_at IS NULL DESC")).order(created_at: :desc)
  }

  # == Methods ==

  sig { returns(T::Boolean) }
  def note_required?
    category == "other"
  end

  # Resolving is idempotent: an admin can revisit a decision, which matters
  # because upholding hides the reportable indefinitely.
  sig { params(resolution: T.any(String, Symbol), moderator: User).void }
  def resolve!(resolution:, moderator:)
    update!(
      resolution:,
      moderator:,
      resolved_at: Time.current,
    )
  end

  private

  # == Callbacks ==

  sig { void }
  def trigger_reportable_callback
    reportable&.after_reported(self)
  end

  sig { void }
  def deliver_created_notification_later
    ReportMailer.created(report: self).deliver_later
  end
end
