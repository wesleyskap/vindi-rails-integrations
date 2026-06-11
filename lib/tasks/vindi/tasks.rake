# frozen_string_literal: true

namespace :vindi do
  desc "Audit and reconcile local model records with Vindi Customers"
  task audit: :environment do
    model_name = ENV["model"] || "User"
    klass = model_name.constantize
    raise "Model #{model_name} is not synchronizable" unless klass.include?(Vindi::Synchronizable)

    audit_records(klass)
  end

  desc "Simulate a Vindi webhook event locally"
  task test_webhook: :environment do
    event_type = ENV["event"] || "bill_paid"
    url = ENV["url"] || "http://localhost:3000/vindi/webhooks"
    token = ENV["token"] || ENV["VINDI_WEBHOOK_TOKEN"]

    payload = build_simulated_payload(event_type)
    send_simulated_webhook(url, token, payload)
  end

  desc "Verify Vindi API credentials and connectivity"
  task status: :environment do
    results = Vindi::Integrations::Diagnostics.run
    print_status_report(results)
  end
end

def print_status_report(results)
  puts "=== Vindi Integration Status ==="
  puts "Environment: #{results[:environment]}"
  puts "API URL:     #{results[:api_url]}"
  puts "API Key:     #{results[:api_key]}"
  puts "Webhook:     #{results[:webhook_token]}"
  puts "--------------------------------"
  
  if results[:connectivity][:status] == "Connected"
    puts "Connectivity: SUCCESS"
  else
    puts "Connectivity: FAILED"
    puts "Error:        #{results[:connectivity][:error]}"
  end
  puts "================================"
end

def audit_records(klass)
  puts "Auditing #{klass.name} records..."
  klass.where.not(vindi_customer_id: nil).find_each do |record|
    Vindi::Customer.find(record.vindi_customer_id)
    puts "Record #{record.id}: OK (Synced with Vindi customer #{record.vindi_customer_id})"
  rescue Vindi::NotFoundError
    puts "Record #{record.id}: ERROR - Customer #{record.vindi_customer_id} not found in Vindi!"
  rescue Vindi::Error => e
    puts "Record #{record.id}: API Error - #{e.message}"
  end
end

def build_simulated_payload(event_type)
  {
    event: {
      id: rand(100_000..999_999),
      type: event_type,
      created_at: Time.current.iso8601,
      data: {
        bill: { id: 555, amount: "100.00", status: "paid" },
        subscription: { id: 777, status: "active" }
      }
    }
  }
end

def send_simulated_webhook(url, token, payload)
  full_url = token ? "#{url}?token=#{token}" : url
  puts "Sending simulated webhook to #{full_url}..."
  
  response = RestClient.post(
    full_url,
    payload.to_json,
    { content_type: :json, accept: :json }
  )
  puts "Response Code: #{response.code}"
  puts "Response Body: #{response.body}"
rescue RestClient::Exception => e
  puts "Failed: #{e.message}"
  puts "Response: #{e.response&.body}"
end
