-- CreateEnum
CREATE TYPE "TipoProva" AS ENUM ('VESTIBULAR', 'PROVA', 'CONCURSO_PUBLICO', 'CERTIFICACAO');

-- CreateEnum
CREATE TYPE "TipoEvento" AS ENUM ('VESTIBULAR', 'CONCURSO_PUBLICO', 'ENEM', 'CERTIFICACAO', 'PROVA_SIMULADA');

-- CreateEnum
CREATE TYPE "StatusInscricao" AS ENUM ('INSCRITO', 'CONFIRMADO', 'CANCELADO', 'REALIZADO');

-- CreateTable
CREATE TABLE "materias" (
    "id" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "descricao" TEXT,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "materias_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "provas" (
    "id" TEXT NOT NULL,
    "titulo" TEXT NOT NULL,
    "descricao" TEXT,
    "data" TIMESTAMP(3) NOT NULL,
    "horario" TIMESTAMP(3) NOT NULL,
    "local" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "materiaId" TEXT,
    "filtros" JSONB,
    "totalQuestoes" INTEGER,
    "acertos" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "provas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "eventos" (
    "id" TEXT NOT NULL,
    "titulo" TEXT NOT NULL,
    "descricao" TEXT,
    "tipo" "TipoEvento" NOT NULL,
    "data" TIMESTAMP(3) NOT NULL,
    "horario" TIMESTAMP(3) NOT NULL,
    "local" TEXT NOT NULL,
    "userId" TEXT,
    "materiaId" TEXT,
    "urlInscricao" TEXT,
    "taxaInscricao" DECIMAL(65,30),
    "dataLimiteInscricao" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "eventos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "evento_inscricoes" (
    "id" TEXT NOT NULL,
    "eventoId" TEXT NOT NULL,
    "usuarioId" TEXT NOT NULL,
    "status" "StatusInscricao" NOT NULL DEFAULT 'INSCRITO',
    "observacoes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "evento_inscricoes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessoes_estudo" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "materiaId" TEXT NOT NULL,
    "provaId" TEXT,
    "eventoId" TEXT,
    "conteudo" TEXT NOT NULL,
    "topicos" TEXT[],
    "tempoInicio" TIMESTAMP(3),
    "tempoFim" TIMESTAMP(3),
    "questoesAcertadas" INTEGER DEFAULT 0,
    "totalQuestoes" INTEGER DEFAULT 0,
    "finalizada" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "sessoes_estudo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Sessao" (
    "id" TEXT NOT NULL,
    "data" TIMESTAMP(3) NOT NULL,
    "duracao" INTEGER NOT NULL,
    "userId" TEXT NOT NULL,
    "provaId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Sessao_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "materias_userId_idx" ON "materias"("userId");

-- CreateIndex
CREATE INDEX "provas_userId_idx" ON "provas"("userId");

-- CreateIndex
CREATE INDEX "eventos_userId_idx" ON "eventos"("userId");

-- CreateIndex
CREATE INDEX "evento_inscricoes_usuarioId_idx" ON "evento_inscricoes"("usuarioId");

-- CreateIndex
CREATE UNIQUE INDEX "evento_inscricoes_eventoId_usuarioId_key" ON "evento_inscricoes"("eventoId", "usuarioId");

-- CreateIndex
CREATE INDEX "sessoes_estudo_userId_idx" ON "sessoes_estudo"("userId");

-- CreateIndex
CREATE INDEX "Sessao_userId_idx" ON "Sessao"("userId");

-- AddForeignKey
ALTER TABLE "provas" ADD CONSTRAINT "provas_materiaId_fkey" FOREIGN KEY ("materiaId") REFERENCES "materias"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "eventos" ADD CONSTRAINT "eventos_materiaId_fkey" FOREIGN KEY ("materiaId") REFERENCES "materias"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evento_inscricoes" ADD CONSTRAINT "evento_inscricoes_eventoId_fkey" FOREIGN KEY ("eventoId") REFERENCES "eventos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessoes_estudo" ADD CONSTRAINT "sessoes_estudo_materiaId_fkey" FOREIGN KEY ("materiaId") REFERENCES "materias"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessoes_estudo" ADD CONSTRAINT "sessoes_estudo_provaId_fkey" FOREIGN KEY ("provaId") REFERENCES "provas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessoes_estudo" ADD CONSTRAINT "sessoes_estudo_eventoId_fkey" FOREIGN KEY ("eventoId") REFERENCES "eventos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Sessao" ADD CONSTRAINT "Sessao_provaId_fkey" FOREIGN KEY ("provaId") REFERENCES "provas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
