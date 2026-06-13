# frozen_string_literal: true

require_relative "test_helper"

class User < ActiveRecord::Base
  include Vindi::Synchronizable
end

class SynchronizableTest < Minitest::Test
  include ActiveJob::TestHelper

  def setup
    WebMock.enable!
    User.delete_all
    Vindi::PendingSync.delete_all
    Vindi.configuration.use_outbox = false
  end

  def teardown
    WebMock.disable!
  end

  def test_creates_vindi_customer_on_record_creation
    stub_request(:post, "https://sandbox-gp.vindi.com.br/api/v1/customers")
      .with(body: { name: "Alice", email: "alice@example.com", code: /^[0-9]+$/ })
      .to_return(status: 201, body: { customer: { id: 7788, name: "Alice", email: "alice@example.com", code: "1" } }.to_json, headers: { "Content-Type" => "application/json" })

    user = User.create!(name: "Alice", email: "alice@example.com")
    
    assert_equal "7788", user.vindi_customer_id
  end

  def test_updates_vindi_customer_on_record_update
    stub_request(:put, "https://sandbox-gp.vindi.com.br/api/v1/customers/7788")
      .with(body: { name: "Alice Smith", email: "alice@example.com", code: /^[0-9]+$/ })
      .to_return(status: 200, body: { customer: { id: 7788, name: "Alice Smith", email: "alice@example.com" } }.to_json, headers: { "Content-Type" => "application/json" })

    # Disable callbacks temporarily to set initial state without triggering API
    user = User.new(name: "Alice", email: "alice@example.com", vindi_customer_id: "7788")
    user.save!(validate: false)

    user.update!(name: "Alice Smith")
  end

  def test_outbox_creates_pending_sync_and_enqueues_job_instead_of_direct_call
    Vindi.configuration.use_outbox = true

    # No stub for POST customers is created yet. If an API call is made synchronously, it will raise WebMock::NetConnectNotAllowedError.
    user = nil
    assert_enqueued_with(job: Vindi::ProcessPendingSyncsJob) do
      user = User.create!(name: "Bob", email: "bob@example.com")
    end

    # The user should not have a vindi_customer_id yet
    assert_nil user.vindi_customer_id

    # There should be a PendingSync record in the database
    sync = Vindi::PendingSync.last
    assert_equal "User", sync.item_type
    assert_equal user.id.to_s, sync.item_id.to_s
    assert_equal "create", sync.action
    assert_equal "pending", sync.status
    assert_equal "Bob", sync.params["name"]
  end

  def test_process_pending_syncs_job_performs_api_call
    Vindi.configuration.use_outbox = true

    user = nil
    assert_enqueued_jobs 1 do
      user = User.create!(name: "Bob", email: "bob@example.com")
    end

    # Stub the API request for when the job runs
    stub_request(:post, "https://sandbox-gp.vindi.com.br/api/v1/customers")
      .with(body: { name: "Bob", email: "bob@example.com", code: user.id.to_s })
      .to_return(status: 201, body: { customer: { id: 9988, name: "Bob", email: "bob@example.com", code: user.id.to_s } }.to_json, headers: { "Content-Type" => "application/json" })

    perform_enqueued_jobs

    user.reload
    assert_equal "9988", user.vindi_customer_id

    sync = Vindi::PendingSync.last
    assert_equal "processed", sync.status
    assert_nil sync.last_error
  end
end
