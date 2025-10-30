-- CreateTable
CREATE TABLE "sensors" (
    "id" TEXT NOT NULL,
    "isListening" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "sensors_pkey" PRIMARY KEY ("id")
);
