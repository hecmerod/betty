-- CreateTable
CREATE TABLE "alarms" (
    "id" INTEGER NOT NULL DEFAULT 1,
    "isActive" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastActivatedAt" TIMESTAMP(3),
    "lastDeactivatedAt" TIMESTAMP(3),
    "lastTriggeredAt" TIMESTAMP(3),

    CONSTRAINT "alarms_pkey" PRIMARY KEY ("id")
);
