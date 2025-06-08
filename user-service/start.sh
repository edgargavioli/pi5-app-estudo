#!/bin/sh

echo "Waiting for database to be ready..."
sleep 5

echo "Generating Prisma client..."
npx prisma generate

echo "Applying migrations..."
npx prisma migrate deploy

echo "Running seed..."
npx prisma db seed

echo "Starting application..."
npm run dev