-- CreateTable
CREATE TABLE "trips" (
    "id" TEXT NOT NULL,
    "startedAt" TIMESTAMP(3) NOT NULL,
    "endedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "trips_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "trips_startedAt_idx" ON "trips"("startedAt");

-- CreateIndex
CREATE INDEX "trips_endedAt_idx" ON "trips"("endedAt");
