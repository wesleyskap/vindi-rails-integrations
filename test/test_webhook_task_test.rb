# frozen_string_literal: true

require_relative "test_helper"
require "rake"

class TestWebhookTaskTest < ActiveSupport::TestCase
  setup do
    WebMock.enable!
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require("tasks/vindi/tasks", [File.expand_path("../../lib", __FILE__)], [])
    Rake::Task.define_task(:environment)
  end

  teardown do
    WebMock.disable!
  end

  test "vindi:test_webhook sends simulated webhook request" do
    stub_request(:post, "http://localhost:3000/vindi/webhooks?token=test_token")
      .to_return(status: 200, body: { status: "received" }.to_json, headers: { "Content-Type" => "application/json" })

    ENV["event"] = "bill_paid"
    ENV["url"] = "http://localhost:3000/vindi/webhooks"
    ENV["token"] = "test_token"

    assert_output(/Response Code: 200/) do
      @rake["vindi:test_webhook"].invoke
    end
  end
end
