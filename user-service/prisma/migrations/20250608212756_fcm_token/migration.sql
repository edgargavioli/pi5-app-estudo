/*
  Warnings:

  - You are about to drop the column `jcmToken` on the `users` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[fcmToken]` on the table `users` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `fcmToken` to the `users` table without a default value. This is not possible if the table is not empty.

*/
-- DropIndex
DROP INDEX "users_jcmToken_key";

-- AlterTable
ALTER TABLE "users" DROP COLUMN "jcmToken",
ADD COLUMN     "fcmToken" TEXT NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "users_fcmToken_key" ON "users"("fcmToken");
