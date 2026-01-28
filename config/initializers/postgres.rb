# typed: true
# frozen_string_literal: true

# See: https://github.com/Shopify/tapioca/issues/2241#issuecomment-2748450848
if Rails.env.development?
  ENV["PGGSSENCMODE"] = "disable"
end
