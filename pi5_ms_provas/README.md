# Microserviço de Provas e Estudos

Este microserviço gerencia provas, matérias e sessões de estudo, implementando uma arquitetura DDD hexagonal e seguindo o nível 3 de maturidade REST (HATEOAS).

## 🚀 Tecnologias

- Node.js
- Express
- PostgreSQL
- Prisma
- Docker
- HATEOAS (Nível 3 REST)

## 📋 Pré-requisitos

- Docker
- Docker Compose
- Node.js 18+

## 🔧 Instalação

1. Clone o repositório
2. Copie o arquivo `.env.example` para `.env` e configure as variáveis:
```bash
cp .env.example .env
```

3. Inicie os containers:
```bash
docker-compose up --build
```

## 📚 Documentação da API

### Matérias

#### Criar Matéria
```http
POST /materias
```

Body:
```json
{
    "nome": "Matemática",
    "disciplina": "Exatas"
}
```

Resposta:
```json
{
    "data": {
        "id": "uuid",
        "nome": "Matemática",
        "disciplina": "Exatas",
        "createdAt": "2024-03-20T10:00:00.000Z",
        "updatedAt": "2024-03-20T10:00:00.000Z"
    },
    "_links": {
        "self": {
            "href": "/materias/uuid",
            "method": "GET"
        },
        "update": {
            "href": "/materias/uuid",
            "method": "PUT"
        },
        "delete": {
            "href": "/materias/uuid",
            "method": "DELETE"
        },
        "provas": {
            "href": "/provas?materiaId=uuid",
            "method": "GET"
        },
        "sessoes": {
            "href": "/sessoes?materiaId=uuid",
            "method": "GET"
        }
    }
}
```

#### Listar Matérias
```http
GET /materias
```

#### Buscar Matéria por ID
```http
GET /materias/:id
```

#### Atualizar Matéria
```http
PUT /materias/:id
```

Body:
```json
{
    "nome": "Matemática Avançada",
    "disciplina": "Exatas"
}
```

#### Deletar Matéria
```http
DELETE /materias/:id
```

### Provas

#### Criar Prova
```http
POST /provas
```

Body:
```json
{
    "tipo": "VESTIBULAR",
    "data": "2024-12-15",
    "horario": "2024-12-15T14:00:00.000Z",
    "local": "Universidade XYZ",
    "materiaId": "uuid-da-materia",
    "pesos": {
        "questoes": 0.6,
        "redacao": 0.4
    },
    "filtros": {
        "dificuldade": "MEDIA",
        "temas": ["Álgebra", "Geometria"]
    }
}
```

Resposta:
```json
{
    "data": {
        "id": "uuid",
        "tipo": "VESTIBULAR",
        "data": "2024-12-15T00:00:00.000Z",
        "horario": "2024-12-15T14:00:00.000Z",
        "local": "Universidade XYZ",
        "materiaId": "uuid-da-materia",
        "pesos": {
            "questoes": 0.6,
            "redacao": 0.4
        },
        "filtros": {
            "dificuldade": "MEDIA",
            "temas": ["Álgebra", "Geometria"]
        },
        "createdAt": "2024-03-20T10:00:00.000Z",
        "updatedAt": "2024-03-20T10:00:00.000Z",
        "materia": {
            "id": "uuid-da-materia",
            "nome": "Matemática",
            "disciplina": "Exatas"
        }
    },
    "_links": {
        "self": {
            "href": "/provas/uuid",
            "method": "GET"
        },
        "update": {
            "href": "/provas/uuid",
            "method": "PUT"
        },
        "delete": {
            "href": "/provas/uuid",
            "method": "DELETE"
        },
        "materia": {
            "href": "/materias/uuid-da-materia",
            "method": "GET"
        },
        "sessoes": {
            "href": "/sessoes?provaId=uuid",
            "method": "GET"
        }
    }
}
```

#### Listar Provas
```http
GET /provas
```

#### Buscar Prova por ID
```http
GET /provas/:id
```

#### Buscar Provas por Matéria
```http
GET /provas?materiaId=uuid
```

#### Buscar Provas por Tipo
```http
GET /provas?tipo=VESTIBULAR
```

#### Buscar Provas com Filtros
```http
GET /provas?dataInicio=2024-01-01&dataFim=2024-12-31&tipo=VESTIBULAR
```

#### Atualizar Prova
```http
PUT /provas/:id
```

Body:
```json
{
    "tipo": "CONCURSO_PUBLICO",
    "data": "2024-12-15",
    "horario": "2024-12-15T14:00:00.000Z",
    "local": "Novo Local",
    "materiaId": "uuid-da-materia",
    "pesos": {
        "questoes": 0.7,
        "redacao": 0.3
    }
}
```

#### Deletar Prova
```http
DELETE /provas/:id
```

### Sessões de Estudo

#### Criar Sessão
```http
POST /sessoes
```

Body:
```json
{
    "materiaId": "uuid-da-materia",
    "provaId": "uuid-da-prova",
    "conteudo": "Revisão de Álgebra Linear",
    "topicos": [
        "Matrizes",
        "Determinantes",
        "Sistemas Lineares"
    ]
}
```

Resposta:
```json
{
    "data": {
        "id": "uuid",
        "materiaId": "uuid-da-materia",
        "provaId": "uuid-da-prova",
        "conteudo": "Revisão de Álgebra Linear",
        "topicos": [
            "Matrizes",
            "Determinantes",
            "Sistemas Lineares"
        ],
        "tempoInicio": "2024-03-20T10:00:00.000Z",
        "tempoFim": null,
        "createdAt": "2024-03-20T10:00:00.000Z",
        "updatedAt": "2024-03-20T10:00:00.000Z",
        "materia": {
            "id": "uuid-da-materia",
            "nome": "Matemática",
            "disciplina": "Exatas"
        },
        "prova": {
            "id": "uuid-da-prova",
            "tipo": "VESTIBULAR",
            "data": "2024-12-15T00:00:00.000Z"
        }
    },
    "_links": {
        "self": {
            "href": "/sessoes/uuid",
            "method": "GET"
        },
        "update": {
            "href": "/sessoes/uuid",
            "method": "PUT"
        },
        "delete": {
            "href": "/sessoes/uuid",
            "method": "DELETE"
        },
        "materia": {
            "href": "/materias/uuid-da-materia",
            "method": "GET"
        },
        "prova": {
            "href": "/provas/uuid-da-prova",
            "method": "GET"
        },
        "finalizar": {
            "href": "/sessoes/uuid/finalizar",
            "method": "POST"
        }
    }
}
```

#### Listar Sessões
```http
GET /sessoes
```

#### Buscar Sessão por ID
```http
GET /sessoes/:id
```

#### Buscar Sessões por Matéria
```http
GET /sessoes?materiaId=uuid
```

#### Buscar Sessões por Prova
```http
GET /sessoes?provaId=uuid
```

#### Buscar Sessões em Andamento
```http
GET /sessoes/em-andamento
```

#### Atualizar Sessão
```http
PUT /sessoes/:id
```

Body:
```json
{
    "conteudo": "Revisão de Cálculo",
    "topicos": [
        "Derivadas",
        "Integrais",
        "Limites"
    ]
}
```

#### Finalizar Sessão
```http
POST /sessoes/:id/finalizar
```

#### Deletar Sessão
```http
DELETE /sessoes/:id
```

## 🔍 Tipos de Prova

- `VESTIBULAR`
- `PROVA`
- `CONCURSO_PUBLICO`
- `CERTIFICACAO`

## 📝 Notas

- Todas as respostas incluem links HATEOAS para navegação
- Datas são retornadas no formato ISO 8601
- IDs são UUIDs
- Erros retornam status 400 com mensagem descritiva
- Recursos não encontrados retornam status 404 