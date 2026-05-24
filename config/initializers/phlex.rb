# typed: true
# frozen_string_literal: true

module Views; end

module Components # rubocop:disable Style/OneClassPerFile
  extend Phlex::Kit
end

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/views"),
  namespace: Views,
)

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/components"),
  namespace: Components,
)
