# typed: true
# frozen_string_literal: true

class Components::Chat::PaginationButton < Components::Base
  sig do
    params(
      group: WhatsappGroup,
      pagy: T.nilable(Pagy),
      options: T.untyped,
    ).void
  end
  def initialize(group:, pagy: nil, **options)
    super()
    @group = group
    @pagy = pagy
    @options = options
  end

  sig { override.void }
  def view_template
    options = {
      to: [ @group, :whatsapp_messages ],
      method: :get,
      form_class: "self-center",
      pagy: @pagy,
      **@options,
    }
    Components::PaginationButton(**T.unsafe(options)) do
      span { @pagy ? "load more messages" : "load messages" }
    end
  end
end
