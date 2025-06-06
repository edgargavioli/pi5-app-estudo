FROM node:20-alpine

WORKDIR /app

# Install dependencies for building native modules
RUN apk add --no-cache \
    openssl \
    openssl-dev \
    python3 \
    make \
    g++

# Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies
RUN npm install

# Generate Prisma client
RUN npx prisma generate

# Copy source code
COPY . .

# Create logs directory
RUN mkdir -p logs

# Expose port
EXPOSE 3000

# Use direct commands instead of start.sh
CMD sh -c "sleep 5 && npx prisma migrate deploy && npx prisma db seed && npm run dev" 