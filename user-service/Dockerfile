FROM node:20-alpine

WORKDIR /app

# Install OpenSSL and other dependencies
RUN apk add --no-cache openssl openssl-dev python3 make g++

# Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies
RUN npm install

# Generate Prisma Client
RUN npx prisma generate

# Copy the rest of the application
COPY . .

# Create logs directory
RUN mkdir -p logs

# Make start script executable
RUN chmod +x start.sh

# Expose the port
EXPOSE 3000

# Start the application using the startup script
CMD ["/bin/sh", "start.sh"] 