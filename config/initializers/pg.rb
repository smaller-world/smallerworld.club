# typed: strict
# frozen_string_literal: true

# See: https://github.com/Shopify/tapioca/issues/2241#issuecomment-2748450848
if Rails.env.development? || (Rails.env.test? && !ENV["CI"])
  ENV["PGGSSENCMODE"] = "disable"
end
