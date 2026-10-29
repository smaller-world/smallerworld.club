# typed: true
# frozen_string_literal: true

class AccountsController < ApplicationController
  # == Configuration ==

  require_unauthenticated_access only: [ :new, :create ]
  skip_verify_authorized

  # == Actions ==

  # GET /account/new
  def new
    respond_to do |format|
      format.html do
        if (registration = find_registration)
          render Views::Accounts::New.new(user: registration.user)
        else
          redirect_to(new_session_path, alert: "please verify your phone number to continue")
        end
      end
    end
  end

  # GET /account/edit
  def edit
    respond_to do |format|
      format.html do
        current_user = Current.user!
        render Views::Accounts::Edit.new(current_user:)
      end
    end
  end

  # POST /account
  def create
    respond_to do |format|
      format.html do
        user_params = params.expect(user: [ :name, :unconfirmed_email_address, :time_zone_name ])
        if (registration = find_registration)
          phone_number_verification_request = registration.phone_number_verification_request!
          registration.transaction do
            user = registration.complete! do |user|
              user.attributes = user_params
            end
            start_new_session_for(user, phone_number_verification_request:)
            session.delete(:registration_token)
            redirect_to(
              after_authentication_url,
              status: :see_other,
              notice: "welcome to smaller world!!",
            )
          rescue Registration::AlreadyCompleted
            session.delete(:registration_token)
            redirect_to(new_session_path, status: :see_other)
          rescue ActiveRecord::RecordInvalid => error
            case (record = error.record)
            when User
              render Views::Accounts::New.new(user: record), status: :unprocessable_content
            else
              raise
            end
          end
        else
          redirect_to(
            new_session_path,
            status: :see_other,
            alert: "something went wrong, please try again!",
          )
        end
      end
    end
  end

  # PUT/PATCH /account
  def update
    respond_to do |format|
      format.html do
        current_user = Current.user!
        user_params = params.expect(user: [
          :name,
          :time_zone_name,
          :unconfirmed_email_address,
        ])
        if current_user.update(user_params)
          if current_user.unconfirmed_email_address? &&
              current_user.saved_change_to_unconfirmed_email_address?
            refresh_or_redirect_to(
              home_path,
              status: :see_other,
              alert: "please check your inbox for a confirmation email! ty <3",
            )
          else
            refresh_or_redirect_to(
              home_path,
              status: :see_other,
              notice: "your account settings were saved",
            )
          end
        else
          render Views::Accounts::Edit.new(current_user:), status: :unprocessable_content
        end
      end
    end
  end

  # DELETE /account
  def destroy
    respond_to do |format|
      format.html do
        current_user = Current.user!
        if current_user.destroy
          redirect_to(root_path, notice: "your account has been deleted. bye-bye!")
        else
          render Views::Accounts::Edit.new(current_user:), status: :unprocessable_content
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(Registration)) }
  def find_registration
    if (token = session[:registration_token])
      Registration.find_by_token(token)
    end
  end
end
