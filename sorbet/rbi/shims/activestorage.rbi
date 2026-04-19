# typed: true

class ActiveStorage::Attached::One
  delegate :signed_id, :blob, to: :attachment
end
