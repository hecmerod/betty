-- CreateTable
CREATE TABLE "device_tokens" (
    "token" TEXT NOT NULL,
    "registeredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsed" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT,
    "platform" TEXT,

    CONSTRAINT "device_tokens_pkey" PRIMARY KEY ("token")
);
