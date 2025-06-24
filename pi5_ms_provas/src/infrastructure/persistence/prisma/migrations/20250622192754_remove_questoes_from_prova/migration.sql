/*
  Warnings:

  - You are about to drop the column `acertos` on the `provas` table. All the data in the column will be lost.
  - You are about to drop the column `totalQuestoes` on the `provas` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "provas" DROP COLUMN "acertos",
DROP COLUMN "totalQuestoes";
