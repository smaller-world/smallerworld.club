# typed: true
# frozen_string_literal: true

module Spaces
  class ApplicationController < ::ApplicationController
    private

    # == Helpers ==

    sig { returns(String) }
    def space_id
      params.fetch(:space_id)
    end

    sig { returns(Space) }
    def find_space
      Space.friendly.find(space_id)
    end
  end
end
