# Integrações Rails da Vindi

[Read in English (README.md)](./README.md)

Uma gem de extensão para a biblioteca base [vindi-rails](https://github.com/wesleyskap/vindi-rails), fornecendo integrações backend como sincronização automática de modelos do ActiveRecord, endpoints de webhook prontos, processamento de tarefas em segundo plano (jobs) e tarefas administrativas Rake.

## Instalação

Adicione esta linha ao Gemfile da sua aplicação:

```ruby
gem 'vindi-rails-integrations'
```

## Recursos e Utilização

### 1. Configuração de Webhooks
Para processar notificações de eventos enviados pela Vindi de forma assíncrona e segura:
```bash
bundle exec rails generate vindi:webhook
```
Isso gera:
- `Vindi::WebhooksController` (`app/controllers/vindi/webhooks_controller.rb`)
- `Vindi::WebhookJob` (`app/jobs/vindi/webhook_job.rb`)

Configure o token de acesso seguro no seu ambiente:
```bash
ENV["VINDI_WEBHOOK_TOKEN"] = "SEU_TOKEN_SEGURO"
```

#### Handlers Modulares de Webhooks
Em vez de centralizar todo o processamento de eventos dentro de um único `WebhookJob` genérico, você pode criar handlers específicos por evento:
```bash
bundle exec rails generate vindi:webhook_handler subscription_canceled
```
Isso gera:
- `Vindi::Webhooks::BaseHandler` (`app/services/vindi/webhooks/base_handler.rb`) - gerado uma vez caso não exista.
- `Vindi::Webhooks::SubscriptionCanceledHandler` (`app/services/vindi/webhooks/subscription_canceled_handler.rb`)

O `WebhookJob` principal detecta e encaminha automaticamente o payload recebido para o handler modular correspondente (ex: `Vindi::Webhooks::SubscriptionCanceledHandler` para o evento `subscription_canceled`), mantendo fallback seguro para tratadores legados inline.

### 2. Sincronização ActiveRecord
Para sincronizar automaticamente modelos locais (ex: `User`) com os Clientes da Vindi:
```bash
bundle exec rails generate vindi:sync User
```
Isso gera uma migração para incluir a coluna `vindi_customer_id` e adiciona o Concern `Vindi::Synchronizable` ao seu modelo.

#### Fila Outbox Transacional Resiliente (Opcional)
Para evitar que latências de rede ou indisponibilidade da API da Vindi travem transações locais do seu banco de dados, você pode habilitar o padrão Outbox. Isso salva as tarefas de sincronização localmente no banco durante a transação e as processa em segundo plano de forma assíncrona.

1. **Gere a migração do Outbox**:
   ```bash
   bundle exec rails generate vindi:outbox
   bundle exec rails db:migrate
   ```
2. **Habilite o Outbox** no seu initializer:
   ```ruby
   Vindi.configure do |config|
     config.use_outbox = true
   end
   ```
3. **Processamento**: O job `Vindi::ProcessPendingSyncsJob` é enfileirado automaticamente após o commit do modelo. Você também pode dispará-lo manualmente ou agendá-lo:
   ```ruby
   Vindi::ProcessPendingSyncsJob.perform_later
   ```

### 3. Tarefas Rake
- **`bundle exec rake vindi:status`**: Valida a configuração da API, ambiente, credenciais (mascaradas com segurança) e testa a conectividade em tempo real.
- **`bundle exec rake vindi:audit model=User`**: Compara os registros locais do banco de dados com a API da Vindi para identificar inconsistências.
- **`bundle exec rake vindi:test_webhook event=bill_paid`**: Envia uma notificação de webhook simulada diretamente para o seu endpoint local de testes.

## Executando os Testes

Para executar a suíte de testes Minitest:
```bash
bundle exec rake test
```
