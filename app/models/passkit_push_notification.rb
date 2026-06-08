# typed: strict
# frozen_string_literal: true

# Silent APNs notification used to tell Apple Wallet that a pass has changed.
# Wallet receives the ping, then calls our PassKit web service to pull the
# refreshed `.pkpass`.
class PasskitPushNotification < DevicePushNotification
  # == Configuration ==

  self.application = "passkit"
end
