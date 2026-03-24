# typed: true
# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    extend T::Sig
    extend T::Helpers

    identified_by :current_user

    sig { void }
    def connect
      set_current_user
    end

    private

    sig { returns(T.nilable(User)) }
    def set_current_user
      if (session = Session.find_by(id: cookies.signed[:session_id]))
        self.current_user = session.user
      end
    end
  end
end
