# typed: true
# frozen_string_literal: true

class Views::WhatsappGroups::MessageHistory < Views::Base
  include Phlex::Rails::Helpers::AssetPath

  # == Configuration ==

  sig { params(group: WhatsappGroup).void }
  def initialize(group:)
    super()
    @group = group
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(body_class: "max-h-dvh") do |layout|
      turbo_stream_from(@group, :message_history)
      layout.page_container(class: "flex-1 min-h-0 flex flex-col gap-y-6") do
        Components::Chat(group: @group)
      end
    end
  end
end
