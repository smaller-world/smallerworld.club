# typed: strict
# frozen_string_literal: true

class InstallationInstructionsQuestions
  extend T::Sig
  extend Enumerize
  include ActiveModel::Model
  include ActiveModel::Attributes

  # == Attributes ==

  attribute :testflight_installed, :boolean
end
