BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "members" (
    "id" bigserial PRIMARY KEY,
    "globalAuthUserId" uuid NOT NULL,
    "localAuthUserId" uuid NOT NULL,
    "email" text,
    "fullName" text,
    "role" text NOT NULL,
    "active" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "global_auth_user_unique_idx" ON "members" USING btree ("globalAuthUserId");
CREATE UNIQUE INDEX "local_auth_user_unique_idx" ON "members" USING btree ("localAuthUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "site_connections" (
    "id" bigserial PRIMARY KEY,
    "globalApiUrl" text NOT NULL,
    "siteId" bigint NOT NULL,
    "siteName" text NOT NULL,
    "adminEmail" text,
    "adminFullName" text,
    "adminAuthUserId" uuid,
    "deviceSessionKey" text,
    "enrolledAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "members"
    ADD CONSTRAINT "members_fk_0"
    FOREIGN KEY("localAuthUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR top_attempt_local
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('top_attempt_local', '20260925151309478', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260925151309478', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260910193913364-string-rate-limit-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260910193913364-string-rate-limit-keys', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();


COMMIT;
