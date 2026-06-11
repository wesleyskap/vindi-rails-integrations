# frozen_string_literal: true

module Vindi
  module Integrations
    class Diagnostics
      def self.run
        new.run
      end

      def run
        {
          api_url: api_url,
          environment: environment_type,
          api_key: masked_api_key,
          webhook_token: masked_webhook_token,
          connectivity: test_connectivity
        }
      end

      private

      def api_url
        Vindi.configuration.api_url
      end

      def environment_type
        api_url.to_s.include?("sandbox") ? "Sandbox" : "Production"
      end

      def masked_api_key
        mask(Vindi.configuration.api_key)
      end

      def masked_webhook_token
        mask(ENV["VINDI_WEBHOOK_TOKEN"])
      end

      def mask(secret)
        return "Not configured" if secret.nil? || secret.empty?
        return "*****" if secret.length <= 4

        "*****#{secret[-4..-1]}"
      end

      def test_connectivity
        Vindi::Customer.list(page: 1, per_page: 1)
        { status: "Connected", error: nil }
      rescue StandardError => e
        { status: "Failed", error: e.message }
      end
    end
  end
end
