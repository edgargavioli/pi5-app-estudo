-- AlterTable
ALTER TABLE "sessoes_estudo" ADD COLUMN     "cumpriuPrazo" BOOLEAN,
ADD COLUMN     "horarioAgendado" TIMESTAMP(3),
ADD COLUMN     "isAgendada" BOOLEAN NOT NULL DEFAULT false;
