# typed: strict
# frozen_string_literal: true

class Components::Form
  class Select < Superform::Rails::Components::Select
    extend T::Generic

    Options = type_member { { upper: T.all(T::Enumerable[T.anything], Object) } }

    # == Initialization ==

    sig do
      override.params(
        field: Field,
        options: Options,
        multiple: T::Boolean,
        include_blank: T::Boolean,
        attributes: T.untyped,
      ).void
    end
    def initialize(field, options:, multiple: false, include_blank: false, **attributes)
      super(field, options:, multiple:, **attributes)
      @include_blank = include_blank
      @options = T.let(@options, Options)
      @multiple = T.let(@multiple, T::Boolean)
      @attributes = T.let(@attributes, T::Hash[Symbol, T.untyped])
      @trigger_block = T.let(
        nil,
        T.nilable(T.proc.params(select: Components::Select).void),
      )
      @content_block = T.let(
        nil,
        T.nilable(T.proc.params(select: Components::Select).void),
      )
    end

    # == Component ==

    sig { override.params(content: T.nilable(T.proc.void)).void }
    def view_template(&content)
      vanish(&content)

      # Hidden input ensures a value is sent even when all options are
      # deselected in a multiple select
      if @multiple
        hidden_name = field.parent.is_a?(Superform::Field) ? dom.name : dom.array_name
        input(type: "hidden", name: hidden_name, value: "")
      end

      Components::Select(**attributes) do |select|
        if @trigger_block
          @trigger_block.call(select)
        else
          select.with_trigger do
            field.human_attribute_name.humanize(capitalize: false)
          end
        end
        if @content_block
          @content_block.call(select)
        else
          select.with_content do |select_content|
            default_item_group(select_content:)
          end
        end
      end
    end

    # == Interface ==

    sig { returns(Options) }
    attr_reader :options

    sig { params(size: Symbol, attributes: T.untyped, content: T.proc.void).void }
    def with_trigger(size: :default, **attributes, &content)
      @trigger_block = ->(select) {
        select = T.let(select, Components::Select)
        select.with_trigger(size:, **attributes, &content)
      }
    end

    sig do
      params(
        anchor: T.any(Symbol, T::Array[Symbol]),
        anchor_strategy: T.nilable(Symbol),
        attributes: T.untyped,
        content: T.proc.params(
          component: Components::Select::Content,
          select: Select[Options],
        ).void,
      ).void
    end
    def with_content(
      anchor: :bottom,
      anchor_strategy: nil,
      **attributes,
      &content
    )
      @content_block = ->(select) {
        select = T.let(select, Components::Select)
        select.with_content(anchor:, **attributes) do |component|
          yield(component, self)
        end
      }
    end

    sig { params(select_content: Components::Select::Content).void }
    def default_item_group(select_content:)
      select_content.group do
        if @include_blank
          select_content.blank_item
        end

        @options.each do |value|
          case value
          in key, value
            select_content.item(value: key) do
              value
            end
          in value
            if value.is_a?(ActiveRecord::Base)
              primary_key = if @options.is_a?(ActiveRecord::Relation)
                @options.primary_key
              else
                value.class.primary_key
              end
              attributes = value.attributes
              id = attributes.delete(primary_key)
              select_content.item(value: id) do
                attributes.values.join(" ")
              end
            else
              select_content.item(value:) do
                value
              end
            end
          end
        end
      end
    end

    protected

    # == Helpers ==

    sig { override.returns(T::Hash[Symbol, T.untyped]) }
    def field_attributes
      {
        id: dom.id,
        name: dom.name,
        value: field.value,
        invalid: field.invalid?,
      }
    end
  end
end
