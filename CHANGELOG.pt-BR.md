# Registro de Alterações - vindi-rails-integrations

Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

## [0.1.0] - 2026-06-10

### Adicionado
- Lançamento inicial de integrações backend para o SDK Vindi Rails.
- **Gerador de Webhooks**: `rails generate vindi:webhook` criando `WebhooksController` com validação de assinatura de token e processamento assíncrono via `WebhookJob`.
- **Gerador de Sincronização**: `rails generate vindi:sync [Model]` gerando migração de banco de dados para `vindi_customer_id` e incluindo o concern `Vindi::Synchronizable`.
- **Tarefas Rake de Administração**:
  - `vindi:audit` reconciliando registros locais do ActiveRecord com a API da Vindi.
  - `vindi:test_webhook` simulando requisições POST de webhook localmente.
- **Suíte de Testes**: Suíte Minitest integrada validando geradores e gatilhos de sincronização com WebMock.
