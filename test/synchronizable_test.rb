# frozen_string_literal: true

require_relative "test_helper"

class User < ActiveRecord::Base
  include Vindi::Synchronizable
end

class SynchronizableTest < Minitest::Test
  def setup
    WebMock.enable!
    User.delete_all
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
end
