# typed: true
# frozen_string_literal: true

module Views; end

module Components
  extend Phlex::Kit
end

autoloader = Rails.autoloaders.main
autoloader.push_dir(Rails.root.join("app/views"), namespace: Views)
autoloader.push_dir(Rails.root.join("app/components"), namespace: Components)
