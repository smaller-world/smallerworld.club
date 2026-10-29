# typed: strict
# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  # == Configuration ==

  setup do
    @user = T.let(users(:bob), User)
  end

  # == Tests ==

  test "new renders the login page" do
    get new_session_path
    assert_response :success
  end

  test "destroy signs the user out" do
    sign_in_as(@user)

    assert_difference -> { @user.sessions.count }, -1 do
      delete session_path
    end
    assert_redirected_to root_path

    assert_empty cookies[:session_id]
  end

  test "a signed out session cookie cannot authenticate again" do
    sign_in_as(@user)
    session_cookie = cookies[:session_id]

    delete session_path
    assert_redirected_to root_path

    cookies[:session_id] = session_cookie
    get home_path
    assert_redirected_to new_session_path
  end
end
