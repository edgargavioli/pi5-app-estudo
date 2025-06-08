#!/bin/sh

echo "Waiting for database to be ready..."
sleep 5

echo "Creating initial migration..."
npx prisma migrate dev --name init --create-only

echo "Applying migrations..."
npx prisma migrate deploy

echo "Running seed..."
npx prisma db seed

echo "Starting application..."
npm run dev 