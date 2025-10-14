-- CreateTable
CREATE TABLE "trip_locations" (
    "id" TEXT NOT NULL,
    "tripId" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "altitude" DOUBLE PRECISION,
    "recordedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "trip_locations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "trip_locations_tripId_idx" ON "trip_locations"("tripId");

-- CreateIndex
CREATE INDEX "trip_locations_recordedAt_idx" ON "trip_locations"("recordedAt");

-- CreateIndex
CREATE INDEX "trip_locations_tripId_recordedAt_idx" ON "trip_locations"("tripId", "recordedAt");

-- AddForeignKey
ALTER TABLE "trip_locations" ADD CONSTRAINT "trip_locations_tripId_fkey" FOREIGN KEY ("tripId") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;
