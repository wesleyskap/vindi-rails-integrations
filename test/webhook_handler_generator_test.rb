# frozen_string_literal: true

require_relative "test_helper"
require "rails/generators/test_case"

class WebhookHandlerGeneratorTest < Rails::Generators::TestCase
  tests Vindi::Generators::WebhookHandlerGenerator
  destination File.expand_path("../tmp", __FILE__)
  setup :prepare_destination

  test "generator copies base handler and specific handler" do
    run_generator ["subscription_canceled"]

    assert_file "app/services/vindi/webhooks/base_handler.rb" do |content|
      assert_match(/class BaseHandler/, content)
    end

    assert_file "app/services/vindi/webhooks/subscription_canceled_handler.rb" do |content|
      assert_match(/class SubscriptionCanceledHandler < BaseHandler/, content)
      assert_match(/# Implement dynamic business action logic for subscription_canceled event here./, content)
    end
  end
end
