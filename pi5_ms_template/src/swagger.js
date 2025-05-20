import swaggerAutogen from "swagger-autogen";

const doc = {
    info: {
        version: "1.0.0",
        title: "Tecnologias Emergentes",
        description: "Documentação da API criada em sala"
    },
    servers: [
        {
            url: "http://localhost:4040",
        }
    ],
    components: {
        schemas: {
            InternalServerError: {
                code: "",
                message: "",
            },
            User: {
                name: "",
                email: "",
                password: "",
            },
            Task: {
                description: "",
            }
        },
        securitySchemes: {
            bearerAuth: {
                type: "http",
                scheme: "bearer",
            }
        }
    }
};

const outputFile = "./config/swagger.json";
const endpointsFiles = ["./presentation/routes/routes.js"];

swaggerAutogen({ openapi: "3.0.0" })(outputFile, endpointsFiles, doc)
    .then(async () => {
        await import("./server.js");
    });
