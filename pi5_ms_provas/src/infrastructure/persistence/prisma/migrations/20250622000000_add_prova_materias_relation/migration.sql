-- CreateTable
CREATE TABLE "prova_materias" (
    "id" TEXT NOT NULL,
    "provaId" TEXT NOT NULL,
    "materiaId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "prova_materias_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "prova_materias_provaId_materiaId_key" ON "prova_materias"("provaId", "materiaId");

-- AddForeignKey
ALTER TABLE "prova_materias" ADD CONSTRAINT "prova_materias_provaId_fkey" FOREIGN KEY ("provaId") REFERENCES "provas"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "prova_materias" ADD CONSTRAINT "prova_materias_materiaId_fkey" FOREIGN KEY ("materiaId") REFERENCES "materias"("id") ON DELETE CASCADE ON UPDATE CASCADE;
