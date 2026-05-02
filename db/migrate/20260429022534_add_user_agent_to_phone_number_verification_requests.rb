class AddUserAgentToPhoneNumberVerificationRequests < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    up_only do
      execute <<~SQL.squish
        DELETE FROM phone_number_verification_requests;
        DELETE FROM sessions;
      SQL
    end

    transaction do
      add_column :phone_number_verification_requests, :user_agent, :string, null: false

      change_table :sessions do |t|
        t.remove :ip_address
        t.remove :user_agent
        t.references :phone_number_verification_request,
          null: false,
          foreign_key: true,
          type: :uuid
      end
    end
  end
end
