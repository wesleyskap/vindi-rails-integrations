# Changelog - vindi-rails-integrations

All notable changes to this project will be documented in this file.

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
