BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "members" DROP COLUMN "fullName";
ALTER TABLE "members" ADD COLUMN "firstName" text;
ALTER TABLE "members" ADD COLUMN "lastName" text;
ALTER TABLE "members" ADD COLUMN "birthday" timestamp without time zone;
ALTER TABLE "members" ADD COLUMN "imageUrl" text;
ALTER TABLE "members" ALTER COLUMN "localAuthUserId" DROP NOT NULL;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "site_connections" DROP COLUMN "adminEmail";
ALTER TABLE "site_connections" DROP COLUMN "adminFullName";
ALTER TABLE "site_connections" ADD COLUMN "siteStreet" text;
ALTER TABLE "site_connections" ADD COLUMN "siteZipCode" text;
ALTER TABLE "site_connections" ADD COLUMN "siteCity" text;
ALTER TABLE "site_connections" ADD COLUMN "siteCountry" text;
ALTER TABLE "site_connections" ADD COLUMN "siteCompanyEmail" text;

--
-- MIGRATION VERSION FOR top_attempt_local
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('top_attempt_local', '20260926112250954', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260926112250954', "timestamp" = now();

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
