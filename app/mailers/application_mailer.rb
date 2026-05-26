# typed: strict
# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  # == Configuration ==

  default from: "robot@smallerworld.club"
  layout "mailer"
end
