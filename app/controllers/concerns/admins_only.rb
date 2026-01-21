# typed: true
# frozen_string_literal: true

module AdminsOnly
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  include Authentication

  requires_ancestor { ApplicationController }

  included do
    T.bind(self, T.class_of(ApplicationController))

    # == Filters ==

    before_action :authorize_admins!
  end

  private

  # == Filter Handlers ==

  sig { void }
  def authorize_admins!
    current_user = authenticate_user!
    authorize!(current_user, to: :administrate?)
  end
end
