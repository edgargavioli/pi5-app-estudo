#!/bin/sh

echo "Waiting for database to be ready..."
sleep 5

echo "Generating Prisma client..."
npx prisma generate --schema=src/infrastructure/persistence/prisma/schema.prisma

echo "Applying migrations..."
npx prisma migrate deploy --schema=src/infrastructure/persistence/prisma/schema.prisma

echo "Starting application..."
npm run start