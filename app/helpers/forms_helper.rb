# typed: true
# frozen_string_literal: true

module FormsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  # == Methods ==

  sig do
    params(record: ActiveRecord::Base, attribute: Symbol)
      .returns(T.nilable(String))
  end
  def error_message_for(record, attribute)
    if (error = record.errors.messages_for(attribute).first)
      [ attribute.to_s.humanize(capitalize: false), error ].join(" ")
    end
  end
end
