# typed: strict
# frozen_string_literal: true

class Components::Form
  class PostRecipientsSelect < Superform::Rails::Components::Field
    # == Initialization ==

    sig { override.params(field: Field, post: Post, attributes: T.untyped).void }
    def initialize(field, post:, **attributes)
      super(field, **attributes)
      @post = post
    end

    # == Component ==

    sig { override.params(content: T.nilable(T.proc.void)).void }
    def view_template(&content)
      Components::PostRecipientsSelect(**T.unsafe({ post: @post, **attributes }))
    end

    protected

    # == Helpers ==

    sig { override.returns(T::Hash[Symbol, T.untyped]) }
    def field_attributes
      {
        input_id_prefix: dom.id,
        name: dom.array_name,
        value: field.value,
        invalid: field.invalid?,
      }
    end
  end
end
