# typed: true
# frozen_string_literal: true

module Spaces
  class ApplicationController < ::ApplicationController
    # == Helpers ==

    sig { returns(String) }
    def space_id
      params.fetch(:space_id)
    end

    sig { params(scope: Space::PrivateRelation).returns(Space) }
    def find_space(scope: Space.all)
      Space.friendly.find(space_id)
    end
  end
end
