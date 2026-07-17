# typed: strict
# frozen_string_literal: true

class Components::Polymorphic < Components::Base
  # == Initialization ==

  sig { params(element: T.nilable(Symbol), attributes: T.untyped).void }
  def initialize(element: nil, **attributes)
    super(**attributes)
    @element = element
  end

  private

  # == Helpers ==

  sig do
    override.params(
      default_element: Symbol,
      attributes: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def root_element(default_element, **attributes, &content)
    public_send(
      @element || default_element,
      **mix(attributes, @attributes),
      &content
    )
  end
end
