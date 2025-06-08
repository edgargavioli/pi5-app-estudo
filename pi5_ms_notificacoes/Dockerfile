FROM node:20-alpine

WORKDIR /app

# Instalar OpenSSL e outras dependências
RUN apk add --no-cache \
    openssl \
    openssl-dev \
    python3 \
    make \
    g++ \
    cairo-dev \
    pango-dev \
    libjpeg-turbo-dev \
    giflib-dev \
    libpng-dev \
    build-base

# Copiar arquivos de dependências
COPY package*.json ./

# Instalar dependências
RUN npm ci && npm cache clean --force

# Copiar todo o código da aplicação primeiro
COPY . .

# Criar pasta config se não existir
RUN mkdir -p config

# Gerar cliente Prisma
RUN npx prisma generate --schema=src/infrastructure/persistence/prisma/schema.prisma

# Criar pasta de logs
RUN mkdir -p logs

RUN chmod +x start.sh

# Expor porta
EXPOSE 4040

# Comando para iniciar a aplicação com migrações
CMD ["/bin/sh", "start.sh"] 