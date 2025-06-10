import swaggerAutogen from "swagger-autogen";

const doc = {
    info: {
        version: "1.0.0",
        title: "API de Provas e Estudos",
        description: "Documentação da API de Provas e Estudos"
    },
    servers: [
        {
            url: "http://localhost:3000",
        }
    ],
    components: {
        schemas: {
            Materia: {
                type: "object",
                properties: {
                    id: { type: "string", format: "uuid", example: "123e4567-e89b-12d3-a456-426614174000" },
                    nome: { type: "string", example: "Matemática" },
                    disciplina: { type: "string", example: "Exatas" },
                    createdAt: { type: "string", format: "date-time" },
                    updatedAt: { type: "string", format: "date-time" }
                }
            },
            Prova: {
                type: "object",
                properties: {
                    id: { type: "string", format: "uuid", example: "123e4567-e89b-12d3-a456-426614174001" },
                    titulo: { type: "string", example: "Prova de Matemática" },
                    descricao: { type: "string", example: "Prova sobre álgebra linear" },
                    data: { type: "string", format: "date", example: "2024-12-25" },
                    horario: { type: "string", format: "date-time", example: "2024-12-25T10:00:00Z" },
                    local: { type: "string", example: "Sala 101" },
                    materiaId: { type: "string", format: "uuid", example: "123e4567-e89b-12d3-a456-426614174000" },
                    pesos: {
                        type: "object",
                        properties: {
                            teoria: { type: "number", example: 0.7 },
                            pratica: { type: "number", example: 0.3 }
                        }
                    }
                }
            },
            SessaoEstudo: {
                type: "object",
                properties: {
                    id: { type: "string", format: "uuid", example: "123e4567-e89b-12d3-a456-426614174002" },
                    materiaId: { type: "string", format: "uuid", example: "123e4567-e89b-12d3-a456-426614174000" },
                    provaId: { type: "string", format: "uuid", example: "123e4567-e89b-12d3-a456-426614174001", nullable: true },
                    conteudo: { type: "string", example: "Estudo sobre derivadas" },
                    topicos: { 
                        type: "array", 
                        items: { type: "string" },
                        example: ["Derivadas", "Integrais", "Limites"]
                    },
                    tempoInicio: { type: "string", format: "date-time", example: "2024-12-25T14:00:00Z" },
                    tempoFim: { type: "string", format: "date-time", nullable: true, example: "2024-12-25T16:00:00Z" }
                }
            },
            Error: {
                type: "object",
                properties: {
                    error: { type: "string", example: "Mensagem de erro" }
                }
            }
        }
    }
};

const outputFile = "./src/config/swagger.json";
const endpointsFiles = [
    "./src/presentation/routes/routes.js"
];

swaggerAutogen({ openapi: "3.0.0" })(outputFile, endpointsFiles, doc)
    .then(() => {
        console.log('📚 Swagger documentation generated successfully!');
        console.log('🔗 Acesse: http://localhost:3000/swagger');
        process.exit(0);
    })
    .catch((error) => {
        console.error('❌ Erro ao gerar swagger:', error);
        process.exit(1);
    }); 