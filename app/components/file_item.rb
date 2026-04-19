# typed: true
# frozen_string_literal: true

class Components::FileItem < Components::Base
  sig { params(attachment: ActiveStorage::Attachment).void }
  def initialize(attachment:)
    super()
    @attachment = attachment
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    raise NotImplementedError
    # Components::Item() do |item|
    # end
  end
end
