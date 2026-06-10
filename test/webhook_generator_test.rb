# frozen_string_literal: true

require_relative "test_helper"
require "rails/generators/test_case"

class WebhookGeneratorTest < Rails::Generators::TestCase
  tests Vindi::Generators::WebhookGenerator
  destination File.expand_path("../tmp", __FILE__)
  setup :prepare_destination

  test "generator copies webhooks controller and job" do
    run_generator

    assert_file "app/controllers/vindi/webhooks_controller.rb" do |content|
      assert_match(/class WebhooksController < ActionController::API/, content)
    end

    assert_file "app/jobs/vindi/webhook_job.rb" do |content|
      assert_match(/class WebhookJob < ActiveJob::Base/, content)
    end
  end
end
