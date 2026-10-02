BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "members" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "memberships" (
    "id" bigserial PRIMARY KEY,
    "globalAuthUserId" uuid NOT NULL,
    "localAuthUserId" uuid,
    "role" text NOT NULL,
    "active" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "membership_global_auth_user_unique_idx" ON "memberships" USING btree ("globalAuthUserId");
CREATE UNIQUE INDEX "membership_local_auth_user_unique_idx" ON "memberships" USING btree ("localAuthUserId");

--
-- ACTION DROP TABLE
--
DROP TABLE "profile_details" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "profile_details" (
    "id" bigserial PRIMARY KEY,
    "membershipId" bigint NOT NULL,
    "email" text,
    "firstName" text,
    "lastName" text,
    "birthday" timestamp without time zone,
    "imageUrl" text
);

-- Indexes
CREATE UNIQUE INDEX "profile_details_membership_unique_idx" ON "profile_details" USING btree ("membershipId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "memberships"
    ADD CONSTRAINT "memberships_fk_0"
    FOREIGN KEY("localAuthUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "profile_details"
    ADD CONSTRAINT "profile_details_fk_0"
    FOREIGN KEY("membershipId")
    REFERENCES "memberships"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR top_attempt_local
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('top_attempt_local', '20260926130244462', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260926130244462', "timestamp" = now();

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
