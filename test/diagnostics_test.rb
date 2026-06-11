# frozen_string_literal: true

require "test_helper"
require "vindi/integrations/diagnostics"

class DiagnosticsTest < ActiveSupport::TestCase
  def setup
    WebMock.enable!
    Vindi.configure do |config|
      config.api_key = "test_key_12345"
      config.api_url = "https://sandbox-gp.vindi.com.br/api/v1"
    end
    ENV["VINDI_WEBHOOK_TOKEN"] = "webhook_secret_999"
  end

  def test_diagnostics_run_success
    stub_request(:get, "https://sandbox-gp.vindi.com.br/api/v1/customers")
      .to_return(status: 200, body: { customers: [] }.to_json, headers: { "Content-Type" => "application/json" })

    result = Vindi::Integrations::Diagnostics.run

    assert_equal "https://sandbox-gp.vindi.com.br/api/v1", result[:api_url]
    assert_equal "Sandbox", result[:environment]
    assert_equal "*****2345", result[:api_key]
    assert_equal "*****_999", result[:webhook_token]
    assert_equal "Connected", result[:connectivity][:status]
    assert_nil result[:connectivity][:error]
  end

  def test_diagnostics_run_failure
    stub_request(:get, "https://sandbox-gp.vindi.com.br/api/v1/customers")
      .to_return(status: 401, body: { error: "Unauthorized" }.to_json, headers: { "Content-Type" => "application/json" })

    result = Vindi::Integrations::Diagnostics.run

    assert_equal "Failed", result[:connectivity][:status]
    assert_match(/HTTP request failed/, result[:connectivity][:error])
  end
end
