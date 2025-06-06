#!/bin/sh

echo "Waiting for database to be ready..."
sleep 5

echo "Installing dependencies..."
npm install

echo "Generating Prisma client..."
npx prisma generate

echo "Deploying migrations..."
npx prisma migrate deploy

echo "Seeding database..."
npx prisma db seed

echo "Starting application..."
npm run dev 