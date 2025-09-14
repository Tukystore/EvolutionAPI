FROM node:18-bullseye-slim

# Instalar dependencias del sistema necesarias
RUN apt-get update && apt-get install -y \
    chromium \
    ca-certificates \
    libnss3 \
    fonts-freefont-ttf \
    git \
    python3 \
    build-essential \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROME_PATH=/usr/bin/chromium

WORKDIR /app

# Clonar el repo
RUN git clone --depth 1 --branch main https://github.com/EvolutionAPI/evolution-api.git .

# Instalar dependencias de producción (más tolerante)
RUN npm install --omit=dev --legacy-peer-deps || true && npm cache clean --force

# Crear usuario no-root y dar permisos
RUN groupadd -g 1001 nodejs && \
    useradd -u 1001 -g nodejs -m evolutionapi && \
    chown -R evolutionapi:nodejs /app

USER evolutionapi

RUN mkdir -p /app/instances

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

CMD ["npm", "run", "start:prod"]
