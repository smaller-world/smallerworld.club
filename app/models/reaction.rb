# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: reactions
#
#  id         :uuid             not null, primary key
#  emoji      :string           not null
#  created_at :timestamptz      not null
#  post_id    :uuid             not null
#  reactor_id :uuid             not null
#
# Indexes
#
#  index_reactions_on_post_id     (post_id)
#  index_reactions_on_reactor_id  (reactor_id)
#  index_reactions_uniqueness     (post_id,emoji,reactor_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (reactor_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Reaction < ApplicationRecord
  # == Associations ==

  belongs_to :post
  belongs_to :reactor, class_name: "User"
end
