BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "site_device_sessions" (
    "id" bigserial PRIMARY KEY,
    "siteId" bigint NOT NULL,
    "serverSideSessionId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "site_unique_idx" ON "site_device_sessions" USING btree ("siteId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "sites" DROP COLUMN "oneTimePasswordHash";
ALTER TABLE "sites" DROP COLUMN "initialAdminPasswordEncrypted";
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "site_device_sessions"
    ADD CONSTRAINT "site_device_sessions_fk_0"
    FOREIGN KEY("siteId")
    REFERENCES "sites"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR top_attempt_global
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('top_attempt_global', '20260925150857366', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260925150857366', "timestamp" = now();

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
