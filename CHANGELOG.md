# Changelog - vindi-rails-integrations

All notable changes to this project will be documented in this file.

## [0.4.0] - 2026-06-13

### Added
- **Resilient Transactional Outbox Sync**: Optional outbox synchronization pattern to queue integration tasks locally inside database transactions, avoiding inline external HTTP API calls.
- **ProcessPendingSyncsJob**: Background ActiveJob runner to process pending database syncs with automatic retries and error logging.
- **Outbox Migration Generator**: CLI generator `rails generate vindi:outbox` to easily create the outbox schema.

## [0.3.0] - 2026-06-12

### Added
- **Modular Webhook Handlers**: Added `rails generate vindi:webhook_handler [EventName]` generator to scaffold decoupled event-specific service handlers under `app/services/vindi/webhooks/`.
- **Dynamic Webhook Dispatching**: Enhanced `WebhookJob` to dynamically resolve and delegate payloads to matching modular service handlers while preserving legacy inline handler fallbacks.
- **Docker Dependency Synchronization**: Fixed container startup dependency mismatch by copying `Gemfile.lock` inside the caching build step in `Dockerfile`.

## [0.2.0] - 2026-06-11

### Added
- **Diagnostics & Connectivity Task**: `rails vindi:status` Rake task to check Vindi API credentials and connectivity safely.
- **Diagnostics Service**: New `Vindi::Integrations::Diagnostics` service to safely mask API and webhook secrets and execute health checks.

## [0.1.0] - 2026-06-10

### Added
- Initial release of backend integrations for the Vindi Rails SDK.
- **Webhook Generator**: `rails generate vindi:webhook` template creating `WebhooksController` with signature token verify and asynchronous ActiveJob handler `WebhookJob`.
- **ActiveRecord Sync Generator**: `rails generate vindi:sync [Model]` adding database migration for `vindi_customer_id` and mixing in `Vindi::Synchronizable` concern.
- **Rake Administrative Tasks**:
  - `vindi:audit` task to reconcile local database against Vindi API.
  - `vindi:test_webhook` task simulating webhook event posts locally.
- **Test Suite**: Integrated Minitest suite verifying generators and sync concern hooks with WebMock.
