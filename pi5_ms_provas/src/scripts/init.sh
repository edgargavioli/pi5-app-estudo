#!/bin/sh

# Aguardar o banco de dados estar pronto
echo "Aguardando o banco de dados..."
while ! nc -z postgres-provas 5432; do
  sleep 1
done
echo "Banco de dados pronto!"

# Verificar se o arquivo .env existe, se não, criar a partir do .env.example
if [ ! -f .env ]; then
    echo "Criando arquivo .env a partir do .env.example..."
    cp .env.example .env
fi

# Aguardar mais um pouco para garantir que o banco está realmente pronto
sleep 5

# Instalar dependências
echo "Instalando dependências..."
npm install

# Limpar cache do Prisma
echo "Limpando cache do Prisma..."
rm -rf node_modules/.prisma

# Gerar o cliente Prisma
echo "Gerando cliente Prisma..."
npx prisma generate

# Aguardar um momento para o cliente ser totalmente gerado
sleep 3

# Criar/atualizar o banco de dados
echo "Criando/atualizando banco de dados..."
npx prisma db push

# Aguardar mais um momento
sleep 3

# Iniciar a aplicação
echo "Inicializando aplicação..."
npm run start 