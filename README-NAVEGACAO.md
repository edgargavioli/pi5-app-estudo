# Navegação e Organização das Telas - PI5 MS Mobile

## Estrutura de Navegação

### 1. Páginas Principais (Bottom Navigation)
As páginas principais são acessadas através da barra de navegação inferior e organizadas em um PageView:

| Índice | Rota | Tela | Descrição | Funcionalidades |
|--------|------|------|-----------|-----------------|
| 0 | `/inicio` | **HomePage** | Tela inicial do app | Dashboard, resumos, próximas provas |
| 1 | `/provas` | **ProvaslistagemPage** | Lista de provas | CRUD provas, filtros, pesquisa |
| 2 | `/cronograma` | **CronogramaPage** | Cronograma de estudos | Visualização calendário, eventos |
| 3 | `/historico` | **HistoricoPage** | Histórico de estudos | Sessões passadas, estatísticas |
| 4 | `/desempenho` | **DesempenhoPage** | Análise de desempenho | Gráficos, métricas, progresso |
| 5 | `/perfil` | **UserProfilePageMain** | Perfil do usuário | Configurações, dados pessoais |

### 2. Fluxo de Autenticação
Telas para login, registro e recuperação de senha:

| Rota | Tela | Descrição |
|------|------|-----------|
| `/auth/login` | **LoginPage** | Login principal |
| `/auth/registro` | **SignupPage** | Cadastro de nova conta |
| `/auth/recuperar-senha` | **RecuperaSenhaPage** | Solicitar recuperação |
| `/auth/verificar-codigo` | **VerificaCodigoPage** | Verificar código enviado |
| `/auth/nova-senha` | **NovaSenhaPage** | Definir nova senha |

### 3. Sub-páginas de Matérias
Páginas específicas para gerenciamento de matérias:

| Rota | Tela | Acesso | Funcionalidades |
|------|------|--------|-----------------|
| `/materias/configuracao` | **ConfigMateriaPage** | Menu superior | CRUD matérias, filtros por disciplina |
| `/materias/listagem` | **MateriasListagemPage** | Navegação programática | Lista para seleção (com parâmetros) |
| `/materias/adicionar` | **AdicionarMateriaPage** | Navegação programática | Formulário de criação |

### 4. Sub-páginas de Provas
Páginas específicas para gerenciamento de provas:

| Rota | Tela | Acesso | Funcionalidades |
|------|------|--------|-----------------|
| `/provas/adicionar` | **AdicionarProvaPage** | Botão FAB, menus | Formulário de criação de prova |
| `/provas/editar` | **EditProvaPage** | Lista de provas | Edição de prova existente |

### 5. Páginas Especiais

| Rota | Tela | Acesso | Funcionalidades |
|------|------|--------|-----------------|
| `/estudos` | **EstudosPage** | Menu superior | Sessões de estudo, cronômetro |
| `/perfil/informacoes` | **UserProfilePageInfo** | Página de perfil | Informações detalhadas do usuário |

## Elementos que Aparecem Múltiplas Vezes

### 1. AppBar com Menu Superior
**Localização**: `ScaffoldWidget` (todas as páginas principais)

**Itens do Menu**:
- **Configurar matérias** → `/materias/configuracao`
- **Sessões de Estudo** → `/estudos`
- **Sair** → Logout dialog → `/auth/login`

### 2. Bottom Navigation Bar
**Localização**: `ScaffoldWidget` (todas as páginas principais)

**Navegação**: Controla o PageView entre as 6 páginas principais

### 3. Floating Action Buttons
- **ProvaslistagemPage**: Adicionar prova → `/provas/adicionar`
- **ConfigMateriaPage**: Salvar configurações
- **AdicionarProvaPage**: Salvar prova

### 4. Componentes Reutilizáveis
- **CardWidget**: Usado em listas de matérias, provas, etc.
- **Loading States**: Indicadores de carregamento
- **Error States**: Telas de erro com retry
- **Confirmation Dialogs**: Para ações destrutivas

## Rotas Programáticas vs Navegação Direta

### Navegação Direta (sempre disponível)
- Bottom navigation entre páginas principais
- Menu superior para configurações e estudos
- Botões de voltar padrão

### Navegação Programática (com parâmetros)
```dart
// Editar prova específica
AppRoutes.navigateTo(context, AppRoutes.provasEditar, 
  arguments: {'prova': provaObject});

// Listar matérias para seleção
AppRoutes.navigateTo(context, AppRoutes.materiasListagem,
  arguments: {'title': 'Selecionar Matéria', 'provaId': 123});

// Adicionar matérias a uma lista
AppRoutes.navigateTo(context, AppRoutes.materiasAdicionar,
  arguments: {'materias': currentMateriasList});
```

## Fluxos de Navegação Principais

### 1. Fluxo de Login
```
/ → /auth/login → /home (com bottom navigation)
```

### 2. Fluxo de Cadastro
```
/auth/login → /auth/registro → /auth/verificar-codigo → /home
```

### 3. Fluxo de Recuperação de Senha
```
/auth/login → /auth/recuperar-senha → /auth/verificar-codigo → /auth/nova-senha → /auth/login
```

### 4. Fluxo de Gerenciamento de Provas
```
/provas (listagem) → /provas/adicionar → voltar para /provas
/provas (listagem) → /provas/editar → voltar para /provas
```

### 5. Fluxo de Configuração de Matérias
```
Qualquer página → Menu → /materias/configuracao → /materias/adicionar → voltar
```

## Navegação Responsiva

### Bottom Navigation (Mobile)
- 6 abas principais
- Labels visíveis
- Ícones intuitivos
- Transições suaves entre páginas

### AppBar (Todas as telas)
- Título centrado
- Menu de opções (⋮)
- Botão voltar automático em sub-páginas

## Gerenciamento de Estado de Navegação

### PageController
- Controla navegação entre páginas principais
- Sincronizado com bottom navigation
- Preserva estado das páginas

### Route Arguments
- Passagem de parâmetros entre telas
- Validação de argumentos obrigatórios
- Fallbacks para argumentos ausentes

### Navigation Stack
- Controle de pilha de navegação
- `pushNamed` para navegação normal
- `pushReplacementNamed` para substituição
- `pushNamedAndRemoveUntil` para reset completo

## Melhorias Implementadas

1. **Rotas Organizadas**: Estrutura hierárquica clara
2. **Nomes Descritivos**: URLs/rotas semânticas
3. **Navegação Consistente**: Padrões uniformes
4. **Acessibilidade**: Labels em todos os elementos
5. **Tratamento de Erros**: Fallbacks para rotas inválidas
6. **Parâmetros Tipados**: Argumentos estruturados
7. **Menu Contextual**: Acesso rápido a funcionalidades importantes

## Telas Ainda Não Integradas

As seguintes telas existem mas podem precisar de ajustes na integração:
- Algumas páginas de autenticação podem ter fluxos incompletos
- Integrações entre páginas de estudos e cronograma
- Links diretos entre histórico e desempenho

## Próximos Passos

1. Implementar autenticação real com tokens
2. Adicionar deep linking para URLs específicas
3. Implementar navegação por gestos
4. Adicionar breadcrumbs em fluxos complexos
5. Implementar cache de navegação
6. Adicionar transições customizadas entre telas 