/*
  Warnings:

  - You are about to drop the `trip_locations` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `trips` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "public"."trip_locations" DROP CONSTRAINT "trip_locations_tripId_fkey";

-- DropTable
DROP TABLE "public"."trip_locations";

-- DropTable
DROP TABLE "public"."trips";
