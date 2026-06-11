# frozen_string_literal: true

require_relative "test_helper"
require "rake"

class AuditTaskTest < ActiveSupport::TestCase
  setup do
    WebMock.enable!
    User.delete_all
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require("tasks/vindi/tasks", [File.expand_path("../../lib", __FILE__)], [])
    Rake::Task.define_task(:environment)
  end

  teardown do
    WebMock.disable!
  end

  test "vindi:audit reconciles successfully when customer is found" do
    user = User.new(name: "Bob", email: "bob@example.com", vindi_customer_id: "9988")
    user.save!(validate: false)

    stub_request(:get, "https://sandbox-gp.vindi.com.br/api/v1/customers/9988")
      .to_return(status: 200, body: { customer: { id: 9988, name: "Bob" } }.to_json, headers: { "Content-Type" => "application/json" })

    ENV["model"] = "User"
    
    assert_output(/Record #{user.id}: OK/) do
      @rake["vindi:audit"].invoke
    end
  end

  test "vindi:audit reports error when customer is not found" do
    user = User.new(name: "Bob", email: "bob@example.com", vindi_customer_id: "9988")
    user.save!(validate: false)

    stub_request(:get, "https://sandbox-gp.vindi.com.br/api/v1/customers/9988")
      .to_return(status: 404, body: { error: "Not found" }.to_json, headers: { "Content-Type" => "application/json" })

    ENV["model"] = "User"
    
    assert_output(/Record #{user.id}: ERROR - Customer 9988 not found/) do
      @rake["vindi:audit"].invoke
    end
  end
end
