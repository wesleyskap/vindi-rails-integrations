# frozen_string_literal: true

require_relative "test_helper"
require "rake"

class StatusTaskTest < ActiveSupport::TestCase
  setup do
    WebMock.enable!
    Vindi.configure do |config|
      config.api_key = "test_key_12345"
      config.api_url = "https://sandbox-gp.vindi.com.br/api/v1"
    end
    ENV["VINDI_WEBHOOK_TOKEN"] = "webhook_secret_999"

    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require("tasks/vindi/tasks", [File.expand_path("../../lib", __FILE__)], [])
    Rake::Task.define_task(:environment)
  end

  teardown do
    WebMock.disable!
  end

  test "vindi:status prints diagnostics status report" do
    stub_request(:get, "https://sandbox-gp.vindi.com.br/api/v1/customers")
      .to_return(status: 200, body: { customers: [] }.to_json, headers: { "Content-Type" => "application/json" })

    assert_output(/Environment: Sandbox\nAPI URL:     https:\/\/sandbox-gp.vindi.com.br\/api\/v1\nAPI Key:     \*\*\*\*\*2345\nWebhook:     \*\*\*\*\*_999\n--------------------------------\nConnectivity: SUCCESS/) do
      @rake["vindi:status"].invoke
    end
  end
end
