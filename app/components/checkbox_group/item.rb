# typed: strict
# frozen_string_literal: true

class Components::CheckboxGroup::Item < Components::Checkbox
  # == Initialization ==

  sig do
    params(
      checkbox_group: Components::CheckboxGroup,
      value: String,
      multiple: T::Boolean,
      checked: T.nilable(T::Boolean),
      disabled: T::Boolean,
      input: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    checkbox_group:,
    value:,
    multiple: true,
    checked: nil,
    disabled: false,
    input: {},
    **attributes
  )
    super(value:, multiple:, checked:, disabled:, input:, **attributes)
    @checkbox_group = checkbox_group
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def checked?
    if @checked.nil?
      if (object = @form&.object) && @field
        current_value = object.try(@field)
        if current_value.is_a?(Enumerable)
          current_value.include?(@value)
        else
          current_value == @value
        end
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
