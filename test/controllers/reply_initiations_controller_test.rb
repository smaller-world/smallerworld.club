# typed: true
# frozen_string_literal: true

require "test_helper"

class ReplyInitiationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = T.let(users(:bob), User)
    @friend = T.let(users(:sue), User)
    @world = T.let(create_world(owner: @owner, name: "Replying World"), World)
    @world.keys.create!(recipient: @friend)
    @post = T.let(create_post(world: @world), Post)
  end

  test "a member initiates a reply and gets a dm link" do
    sign_in_as(@friend)
    assert_difference -> { @post.reply_initiations.count }, 1 do
      post post_reply_initiations_path(@post),
        params: {
          reply_initiation: {
            platform: "sms",
          },
        },
        as: :turbo_stream
    end
    assert_response :success

    # The owner's phone number drives the sms reply link.
    assert_includes response.body, "sms:#{@owner.phone_number}"
  end
end
