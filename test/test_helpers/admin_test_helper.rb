# typed: strict
# frozen_string_literal: true

# Admin status is derived from `credentials.admin_phone_numbers`. Tests stub
# the resolved set rather than depending on the real numbers in credentials.
module AdminTestHelper
  extend T::Sig

  # == Methods ==

  sig do
    type_parameters(:R)
      .params(users: User, block: T.proc.returns(T.type_parameter(:R)))
      .returns(T.type_parameter(:R))
  end
  def with_admins(*users, &block)
    phone_numbers = Set.new(users.map(&:phone_number))
    SmallerWorld.application.stub(:admin_phone_numbers, phone_numbers, &block)
  end
end

ActiveSupport.on_load(:active_support_test_case) do
  include AdminTestHelper
end
