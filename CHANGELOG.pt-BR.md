# Registro de Alterações - vindi-rails-integrations

Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

## [0.3.0] - 2026-06-12

### Adicionado
- **Handlers Modulares de Webhooks**: Adicionado o gerador `rails generate vindi:webhook_handler [EventName]` para criar tratadores de eventos de serviço desacoplados em `app/services/vindi/webhooks/`.
- **Despacho Dinâmico de Webhooks**: Atualizado o `WebhookJob` para resolver e delegar payloads dinamicamente aos handlers modulares correspondentes, mantendo a compatibilidade e fallbacks para implementações legadas.
- **Sincronização de Dependências no Docker**: Corrigido o Dockerfile para incluir o `Gemfile.lock` na etapa de cache do bundler, evitando incompatibilidades de versão de gemas em runtime.

## [0.2.0] - 2026-06-11

### Adicionado
- **Tarefa de Diagnóstico e Conectividade**: Task Rake `rails vindi:status` para verificar de forma segura as credenciais e conectividade com a API da Vindi.
- **Serviço de Diagnóstico**: Nova classe `Vindi::Integrations::Diagnostics` que mascara tokens sensíveis da API/webhooks e executa testes de saúde de conexão.

## [0.1.0] - 2026-06-10

### Adicionado
- Lançamento inicial de integrações backend para o SDK Vindi Rails.
- **Gerador de Webhooks**: `rails generate vindi:webhook` criando `WebhooksController` com validação de assinatura de token e processamento assíncrono via `WebhookJob`.
- **Gerador de Sincronização**: `rails generate vindi:sync [Model]` gerando migração de banco de dados para `vindi_customer_id` e incluindo o concern `Vindi::Synchronizable`.
- **Tarefas Rake de Administração**:
  - `vindi:audit` reconciliando registros locais do ActiveRecord com a API da Vindi.
  - `vindi:test_webhook` simulando requisições POST de webhook localmente.
- **Suíte de Testes**: Suíte Minitest integrada validando geradores e gatilhos de sincronização com WebMock.
