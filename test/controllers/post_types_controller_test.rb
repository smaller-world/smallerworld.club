# typed: strict
# frozen_string_literal: true

require "test_helper"

class PostTypesControllerTest < ActionDispatch::IntegrationTest
  test "owner returns to the form after submitting a duplicate post type" do
    owner = users(:bob)
    world = create_world(owner:)
    sign_in_as(owner)

    assert_no_difference -> { world.post_types.count } do
      post world_post_types_path(world), params: { post_type: { name: "journal entry" } }
    end

    assert_response :unprocessable_content
    assert_select "form[action=?]", world_post_types_path(world)
  end
end
