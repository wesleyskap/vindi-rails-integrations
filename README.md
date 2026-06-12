# Vindi Rails Integrations

[Leia em Português (README.pt-BR.md)](./README.pt-BR.md)

An extension gem for the [vindi-rails](https://github.com/wesleyskap/vindi-rails) core SDK, providing backend integrations such as automatic ActiveRecord model synchronization, webhook controller endpoints, asynchronous processing jobs, and verification Rake tasks.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vindi-rails-integrations'
```

## Features & Usage

### 1. Webhook Setup
To handle incoming webhook events asynchronously with built-in access token verification:
```bash
bundle exec rails generate vindi:webhook
```
This generates:
- `Vindi::WebhooksController` (`app/controllers/vindi/webhooks_controller.rb`)
- `Vindi::WebhookJob` (`app/jobs/vindi/webhook_job.rb`)

Configure your webhook access token in your environment files:
```bash
ENV["VINDI_WEBHOOK_TOKEN"] = "YOUR_SECURE_TOKEN"
```

#### Modular Webhook Handlers
Instead of processing all webhook events inside a single `WebhookJob`, you can generate modular event-specific handlers:
```bash
bundle exec rails generate vindi:webhook_handler subscription_canceled
```
This generates:
- `Vindi::Webhooks::BaseHandler` (`app/services/vindi/webhooks/base_handler.rb`) - created once if missing.
- `Vindi::Webhooks::SubscriptionCanceledHandler` (`app/services/vindi/webhooks/subscription_canceled_handler.rb`)

The main `WebhookJob` automatically detects and forwards the event payload to matching handlers (e.g. `Vindi::Webhooks::SubscriptionCanceledHandler` for `subscription_canceled` events) with safe fallback to legacy inline handlers.

### 2. ActiveRecord Model Sync
To automatically synchronize local models (e.g. `User`) with Vindi Customers:
```bash
bundle exec rails generate vindi:sync User
```
This generates a database migration to add `vindi_customer_id` and includes the `Vindi::Synchronizable` concern into your model.

### 3. Rake Tasks
- **`bundle exec rake vindi:status`**: Verifies API configuration, environment, credentials (safely masked), and tests connection to Vindi.
- **`bundle exec rake vindi:audit model=User`**: Reconciles database records against the Vindi API to detect missing or mismatched records.
- **`bundle exec rake vindi:test_webhook event=bill_paid`**: Simulates sending a webhook event payload directly to your local endpoint.

## Running Tests

To run the Minitest suite:
```bash
bundle exec rake test
```
