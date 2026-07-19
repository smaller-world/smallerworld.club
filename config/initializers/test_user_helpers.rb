# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig { returns(T.untyped) }
  def test_user_credentials
    credentials.test_user!
  end

  sig { returns(String) }
  def test_user_phone_number
    @test_user_phone_number ||= T.let(
      Phonelib.parse(test_user_credentials.phone_number!).to_s,
      T.nilable(String),
    )
  end

  sig { returns(String) }
  def test_user_verification_code
    test_user_credentials.verification_code!
  end
end
