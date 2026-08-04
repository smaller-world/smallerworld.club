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
#  resolved_at     :timestamptz
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  reportable_id   :uuid             not null
#  reporter_id     :uuid             not null
#
# Indexes
#
#  index_reports_on_reportable   (reportable_type,reportable_id)
#  index_reports_on_reporter_id  (reporter_id)
#  index_reports_on_resolved_at  (resolved_at)
#
# Foreign Keys
#
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

  # == Associations ==

  belongs_to :reportable, polymorphic: true
  belongs_to :reporter, class_name: "User"

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

  # == Scopes ==

  scope :unresolved, -> { where(resolved_at: nil) }
  scope :resolved, -> { where.not(resolved_at: nil) }

  # == Methods ==

  sig { returns(T::Boolean) }
  def note_required?
    category == "other"
  end
end
