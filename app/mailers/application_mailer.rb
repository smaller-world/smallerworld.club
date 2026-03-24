# typed: true
# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  # == Configuration ==

  default from: "robot@happytown.life"
  layout "mailer"
end
