# Sistema de Notas Fiscais com Microserviços

Este projeto implementa um sistema de notas fiscais utilizando uma arquitetura de microserviços em Delphi com RAD Server 10.1 e banco de dados Firebird.

## Estrutura do Projeto

O projeto está dividido em dois microserviços principais:

### 1. Serviço de Estoque 
- Porta: 8081
- Responsável pelo gerenciamento de produtos e controle de estoque
- Endpoints:
  - GET /produtos/:id - Obtém um produto específico
  - POST /produtos - Cria um novo produto
  - PUT /produtos/:id/atualizar-estoque - Atualiza o estoque de um produto

### 2. Serviço de Faturamento 
- Porta: 8082
- Responsável pelo gerenciamento de notas fiscais
- Endpoints:
  - GET /notas - Lista todas as notas fiscais
  - GET /notas/:id - Obtém uma nota fiscal específica
  - POST /notas - Cria uma nova nota fiscal
  - POST /notas/:id/itens - Consulta os itens da nota fiscal
  - POST /notas/status - Muda status nota fiscal

## Funcionalidades

1. Cadastro de Produtos
   - Informações básicas (código, descrição, preço)
   - Controle de saldo de estoque

2. Gerenciamento de Notas Fiscais
   - Numeração automática
   - Status (aberto/fechado)
   - Múltiplos produtos por nota
   - Validação de estoque ao imprimir
   - Baixa automática de estoque ao imprimir
   - Feedback ao usuário sobre o processamento

## Conceitos Implementados

1. ACID (Atomicity, Consistency, Isolation, Durability)
   - Transações atômicas no banco de dados
   - Consistência entre os serviços
   - Isolamento de operações
   - Durabilidade dos dados

2. Tratamento de Falhas
   - Recuperação de falhas entre serviços
   - Rollback em caso de erros
   - Feedback adequado ao usuário

3. Concorrência
   - Controle de concorrência no banco de dados
   - Validação de estoque em tempo real

## Configuração

1. Anexar o banco de dados em:
   - C:\KorpTeste\database\KORP.FDB

3. Compilar e executar os serviços:
   - InventoryService.dpr (porta 8081)
   - BillingService.dpr (porta 8082)


## Tratamento de Erros

O sistema implementa tratamento robusto de erros, incluindo:

1. Validação de estoque insuficiente
2. Falhas na comunicação entre serviços
3. Erros de banco de dados
4. Validações de regras de negócio

Em todos os casos, o usuário receberá feedback apropriado sobre o erro ocorrido.
