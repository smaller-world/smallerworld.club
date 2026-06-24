# typed: strict
# frozen_string_literal: true

class Passkit::ApplicationPass < Passkit::BasePass
  extend T::Sig

  # == Configuration ==

  sig { returns(Pathname) }
  def pass_path
    Rails.root.join("app/assets/passkit/#{folder_name}")
  end
end
