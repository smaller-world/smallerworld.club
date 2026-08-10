# typed: strict
# frozen_string_literal: true

class SmallerWorld::Application
  # Phone numbers of users with admin privileges, in E.164 format (matching
  # how `User#phone_number` is normalized).
  sig { returns(T::Set[String]) }
  def admin_phone_numbers
    @admin_phone_numbers ||= T.let(
      Set.new(credentials.admin_phone_numbers || []),
      T.nilable(T::Set[String]),
    )
  end
end
