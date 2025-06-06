FROM node:18-alpine

WORKDIR /app

# Instalar dependências necessárias
RUN apk add --no-cache \
    netcat-openbsd \
    openssl \
    openssl-dev \
    python3 \
    make \
    g++

# Copiar arquivos de dependências
COPY package*.json ./

# Instalar dependências
RUN npm cache clean --force
RUN npm install

# Copiar o resto dos arquivos
COPY . .

# Gerar o cliente Prisma
RUN npx prisma generate

# Tornar o script executável
RUN chmod +x src/scripts/init.sh

# Criar diretório para logs
RUN mkdir -p logs && chmod 777 logs

EXPOSE 3000

CMD ["./src/scripts/init.sh"] 