# frozen_string_literal: true

module Vindi
  class WebhooksController < ActionController::API
    before_action :verify_token!

    def create
      payload = JSON.parse(request.body.read, symbolize_names: true)
      
      # Enqueue Vindi Webhook processing
      Vindi::WebhookJob.perform_later(payload)

      render json: { status: "received" }, status: :ok
    rescue JSON::ParserError
      render json: { error: "Invalid payload" }, status: :bad_request
    end

    private

    # SECURITY BEST PRACTICE: Verify the authenticity of the request.
    # Configure your Webhook URL in the Vindi Dashboard with a secret query token, e.g.:
    # https://yourdomain.com/vindi/webhooks?token=YOUR_SECURE_TOKEN
    def verify_token!
      token = params[:token]
      expected_token = ENV["VINDI_WEBHOOK_TOKEN"]

      if expected_token.blank? || token != expected_token
        render json: { error: "Unauthorized access token" }, status: :unauthorized
      end
    end
  end
end
