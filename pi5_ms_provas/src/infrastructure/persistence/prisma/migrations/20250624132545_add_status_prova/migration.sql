-- CreateEnum
CREATE TYPE "StatusProva" AS ENUM ('PENDENTE', 'CONCLUIDA', 'CANCELADA');

-- AlterTable
ALTER TABLE "provas" ADD COLUMN     "status" "StatusProva" NOT NULL DEFAULT 'PENDENTE';
