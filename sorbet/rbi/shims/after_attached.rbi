# typed: strict
# frozen_string_literal: true

class ActiveRecord::Base
  include AfterAttached::AttachmentCallbacks
end
