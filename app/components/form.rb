# typed: strict
# frozen_string_literal: true

class Components::Form < Superform::Rails::Form
  extend T::Sig
  extend T::Helpers
  extend T::Generic
  include CompactMixing

  Elem = type_member
  Option = T.type_alias do
    T.any(
      ActiveRecord::Relation,
      ActiveRecord::AssociationRelation,
      T::Hash[String, Object],
      [ String, Object ],
      Object,
    )
  end

  # == Initialization ==

  sig do
    params(
      model: T.all(Elem, Object),
      action: Object,
      method: T.nilable(Symbol),
      vibrate_on_submit: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    model,
    action: model,
    method: nil,
    vibrate_on_submit: false,
    **attributes
  )
    super(model, action:, method:, **attributes)
    @model = T.let(@model, T.all(Elem, Object))
    @action = T.let(@action, Object)
    @method = T.let(@method, T.nilable(Symbol))
    @namespace = T.let(@namespace, Superform::Namespace)
    @vibrate_on_submit = vibrate_on_submit
  end

  # == Component ==

  sig { params(content: T.proc.void).void }
  def around_template(&content)
    form_tag do
      unless @method == :get
        authenticity_token_field
        _method_field
      end
      yield
    end
  end

  # == Interface ==

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.proc.params(button: Components::Button).returns(T.untyped),
    ).void
  end
  def submit(variant: :default, size: :default, **attributes, &content)
    Components::Button(
      type: :submit,
      name: "commit",
      variant:,
      size:,
      **attributes,
      &content
    )
  end

  # Renders the component in a row with label and error
  sig do
    params(
      component: Superform::Rails::Components::Field,
      orientation: Symbol,
      label: T.any(T::Boolean, String),
      description: T.nilable(String),
      label_class: T.nilable(String),
      error: T.any(T::Hash[Symbol, T.untyped], T::Boolean),
      attributes: T.untyped,
      content: T.nilable(T.proc.params(row: Components::Field).void),
    ).void
  end
  def wrapped(
    component,
    orientation: :vertical,
    label: true,
    description: nil,
    label_class: nil,
    error: true,
    **attributes,
    &content
  )
    Components::Field(
      orientation:,
      invalid: component.field.invalid?,
      **attributes,
    ) do |row|
      unless label == false
        label_content = if label.is_a?(String)
          proc { label }
        end
        render component.field.label(class: label_class, &label_content)
      end
      render component
      if description.present?
        row.description { description }
      end
      if block_given?
        yield(row)
      end
      if error
        error_attributes = error.is_a?(Hash) ? error : {}
        render Error.new(component.field, **error_attributes)
      end
    end
  end

  sig { params(key: Symbol).returns(T::Boolean) }
  def invalid?(key)
    field(key).invalid?
  end

  sig { params(key: Symbol, attributes: T.untyped).void }
  def error_for(key, **attributes)
    render Error.new(field(key), **attributes)
  end

  sig { params(key: Symbol).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def error_tooltip_attributes_for(key)
    field(key).error_tooltip_attributes
  end

  protected

  # == Helpers ==

  sig { override.params(content: T.proc.void).void }
  def form_tag(&content)
    form(
      action: form_action,
      method: form_method,
      **form_attributes,
      &content
    )
  end

  sig { returns(String) }
  def form_action
    if @action.is_a?(String)
      @action
    else
      url_for(@action)
    end
  end

  sig { overridable.returns(T::Hash[Symbol, T.untyped]) }
  def form_attributes
    mix(
      {
        class: "form",
        data: {
          slot: "form",
        },
      },
      haptic_form_attributes,
      @attributes,
    )
  end

  sig { returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def haptic_form_attributes
    if @vibrate_on_submit
      {
        data: {
          controller: "haptic-bridge",
          action: "turbo:submit-end->haptic-bridge#vibrate",
        },
      }
    end
  end

  # sig { params(content: T.nilable(T.proc.void)).void }
  # def around_template(&content)
  #   super do
  #     # Renders error messages if there are any validation errors on the model
  #     errors_alert

  #     # Renders the contents of the form from `view_template` or the block passed
  #     # the #render method.
  #     yield if block_given?

  #     # Renders the submit button for the form.
  #     submit
  #   end
  # end

  # # This is needed for the `error_messages`
  # include Phlex::Rails::Helpers::Pluralize

  # # Displays error messages for the form's model if there are any validation errors.
  # def errors_alert
  #   if model.errors.any?
  #     div(style: "color: red;") do
  #       h2 { "#{pluralize(model.errors.count, "error")} prohibited this post from being saved:" }
  #       ul do
  #         model.errors.each do |error|
  #           li { error.full_message }
  #         end
  #       end
  #     end
  #   end
  # end

  # # Wraps a form field and its label in a div for layout purposes.
  # def row(component)
  #   div do
  #     render component.field.label(style: "display: block;")
  #     render component
  #   end
  # end
end
