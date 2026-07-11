# typed: strict
# frozen_string_literal: true

module RenderJsonError
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionController::Base }

  private

  # == Methods ==

  sig { params(error: Exception).void }
  def render_json_error(error)
    message = error.message
    status = :internal_server_error
    if error.is_a?(ActiveRecord::RecordInvalid)
      if (first_message = error.record.errors.full_messages.first)
        message = first_message
      end
      status = :unprocessable_content
    end
    render(json: { error: message }, status:)
  end
end
