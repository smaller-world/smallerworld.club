# typed: true
# frozen_string_literal: true

class Components::Chat::Messages < Components::Base
  # == Configuration ==

  sig { params(messages: T::Array[WhatsappMessage]).void }
  def initialize(messages:)
    super()
    @messages = messages
  end

  # == Component ==

  sig { override.void }
  def view_template
    @messages.each do |message|
      render Item.new(message:)
    end
  end
end
