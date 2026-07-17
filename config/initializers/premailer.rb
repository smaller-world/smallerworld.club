# typed: strict
# frozen_string_literal: true

Premailer::Rails.config.merge!(
  create_shorthands: false,
  remove_classes: true,
  remove_comments: true,
  verbose: Rails.env.development?,
)
