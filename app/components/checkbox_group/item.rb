# typed: strict
# frozen_string_literal: true

class Components::CheckboxGroup::Item < Components::Checkbox
  # == Initialization ==

  sig do
    params(
      checkbox_group: Components::CheckboxGroup,
      value: T.any(Symbol, String, Enumerize::Value),
      checked: T.nilable(T::Boolean),
      multiple: T::Boolean,
      input: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    checkbox_group:,
    value:,
    checked: nil,
    multiple: true,
    input: {},
    **attributes
  )
    super(value:, checked:, input:, multiple:, **attributes)
    @checkbox_group = checkbox_group
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def checked?
    if @checked.nil?
      if (object = @form&.object) && @field
        object.public_send(@field) == @value
      else
        false
      end
    else
      @checked
    end
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def input_options
    options = super
    options[:id] ||= field_id(@checkbox_group.namespace, @value)
    options[:aria] ||= {}
    options[:aria][:labelledby] = field_id(@checkbox_group.namespace, @value, :label)
    options
  end
end
