FROM node:18-alpine

# Definir diretório de trabalho
WORKDIR /usr/src/app

# Instalar dependências necessárias (incluindo netcat para o script)
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

# Copiar o resto dos arquivos (incluindo src/scripts/init.sh)
COPY . .

# Gerar o cliente Prisma
RUN npx prisma generate

# Tornar o script de inicialização executável
RUN chmod +x init.sh

# Criar diretório para logs
RUN mkdir -p logs && chmod 777 logs

EXPOSE 3000

# Executar o script de inicialização
CMD ["./src/scripts/init.sh"]