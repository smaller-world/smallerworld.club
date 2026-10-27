# typed: true
# frozen_string_literal: true

require "test_helper"
require "timeout"

class PhoneNumberVerificationConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  teardown do
    if @request
      Session.where(phone_number_verification_request: @request).destroy_all
      User.find_by(phone_number: @request.phone_number)&.destroy!
      @request.destroy!
    end
  end

  test "concurrent code submissions consume once with no loser mutation" do
    @request = create_request
    user = User.create!(**attributes("owner"), phone_number: @request.phone_number)
    results = compete do |request, index|
      request.submit_code!(
        request.verification_code,
        time_zone_name: index.zero? ? "America/Toronto" : "Europe/London",
      )
    end
    winner = results.find { |_, result| result.is_a?(Session) }
    assert_equal 1, results.count { |_, result| result.is_a?(Session) }
    assert_equal 1, results.count { |_, result| result.is_a?(ActiveRecord::RecordInvalid) }
    assert_equal 1, user.sessions.count
    assert_equal winner.first.zero? ? "America/Toronto" : "Europe/London", user.reload.time_zone_name
    assert_predicate @request.reload, :consumed_at?
  end

  test "concurrent registrations create one account and one session" do
    @request = create_request
    @request.submit_code!(@request.verification_code)
    results = compete { |request, index| request.complete_registration!(attributes("friend #{index}")) }
    winner = results.find { |_, result| result.is_a?(Session) }
    assert_equal 1, results.count { |_, result| result.is_a?(Session) }
    assert_equal 1, results.count { |_, result| result.is_a?(ActiveRecord::RecordInvalid) }
    assert_equal 1, Session.where(phone_number_verification_request: @request).count
    assert_equal 1, User.where(phone_number: @request.phone_number).count
    assert_equal "friend #{winner.first}", User.find_by!(phone_number: @request.phone_number).name
  end

  test "concurrent direct session creation cannot bypass consumption" do
    @request = create_request
    user = User.create!(**attributes("owner"), phone_number: @request.phone_number)
    @request.update!(verified_at: Time.current)
    results = compete do |request, _|
      Session.create!(user: User.find(user.id), phone_number_verification_request: request)
    end
    assert_equal 1, results.count { |_, result| result.is_a?(Session) }
    assert_equal 1, results.count { |_, result| result.is_a?(ActiveRecord::RecordInvalid) }
    assert_equal 1, user.sessions.count
  end

  private

  def create_request
    PhoneNumberVerificationRequest.create!(phone_number: "+14165554321", user_agent: "test", ip_address: "127.0.0.1")
  end

  def attributes(name)
    { name:, unconfirmed_email_address: "concurrency@example.com", time_zone_name: "America/Toronto" }
  end

  # Hold the row until BOTH independently loaded callers are blocked on its lock.
  # This proves overlap without timing guesses or sharing fixture transactions.
  def compete
    ready = Queue.new
    threads = T.let([], T::Array[Thread])
    @request.with_lock do
      threads = Array.new(2) do |index|
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do |connection|
            request = PhoneNumberVerificationRequest.find(@request.id)
            ready << connection.select_value("SELECT pg_backend_pid()")
            begin
              [ index, yield(request, index) ]
            rescue ActiveRecord::RecordInvalid => error
              [ index, error ]
            end
          end
        end
      end
      pids = Array.new(2) { Timeout.timeout(10) { ready.pop } }
      Timeout.timeout(10) do
        loop do
          ActiveRecord::Base.connection.execute("SELECT pg_stat_clear_snapshot()")
          waiting = ActiveRecord::Base.connection.select_value(
            "SELECT COUNT(*) FROM pg_stat_activity WHERE pid IN (#{pids.map { |pid| Integer(pid) }.join(",")}) AND wait_event_type = 'Lock'",
          )
          break if waiting == 2

          sleep(0.01)
        end
      end
    end
    threads.map { |thread| Timeout.timeout(10) { thread.value } }
  ensure
    threads&.each do |thread|
      thread.kill if thread.alive?
      thread.join
    end
  end
end
