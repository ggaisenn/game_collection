-- game_tracker_role_setup.sql
-- Target: MySQL 8.0+ (roles supported)
-- Run as a DBA/admin account after schema.sql has created the tables.
-- Change the example passwords before deployment. Do not use these in production.

USE game_tracker;

-- 1) Create database roles
CREATE ROLE IF NOT EXISTS 'gamer_role', 'admin_role', 'game_developer_role';

-- 2) GAMER: read-only access to public game catalog and reference data.
-- Writes to personal records should go through an application/API or
-- SQL SECURITY DEFINER procedures that verify the logged-in account owns user_id.
GRANT SELECT ON game_tracker.Game TO 'gamer_role';
GRANT SELECT ON game_tracker.Developer TO 'gamer_role';
GRANT SELECT ON game_tracker.Publisher TO 'gamer_role';
GRANT SELECT ON game_tracker.Genre TO 'gamer_role';
GRANT SELECT ON game_tracker.Category TO 'gamer_role';
GRANT SELECT ON game_tracker.Platform TO 'gamer_role';
GRANT SELECT ON game_tracker.Game_Developer TO 'gamer_role';
GRANT SELECT ON game_tracker.Game_Publisher TO 'gamer_role';
GRANT SELECT ON game_tracker.Game_Genre TO 'gamer_role';
GRANT SELECT ON game_tracker.Game_Category TO 'gamer_role';
GRANT SELECT ON game_tracker.Game_Platform TO 'gamer_role';
GRANT SELECT ON game_tracker.Achievement TO 'gamer_role';

-- 3) ADMIN: read and modify records in this database, but no account/role administration
-- and no schema DDL. Keep MySQL DBA credentials separate.
GRANT SELECT, INSERT, UPDATE, DELETE ON game_tracker.* TO 'admin_role';

-- 4) GAME DEVELOPER: read catalog and analytics source tables; manage game catalog
-- metadata and achievements. Application authorization must restrict each developer
-- to games assigned to them (the schema currently has no DB-enforced ownership rule).
GRANT SELECT ON game_tracker.* TO 'game_developer_role';
GRANT INSERT, UPDATE, DELETE ON game_tracker.Game TO 'game_developer_role';
GRANT INSERT, UPDATE, DELETE ON game_tracker.Developer TO 'game_developer_role';
GRANT INSERT, UPDATE, DELETE ON game_tracker.Publisher TO 'game_developer_role';
GRANT INSERT, UPDATE, DELETE ON game_tracker.Genre TO 'game_developer_role';
GRANT INSERT, UPDATE, DELETE ON game_tracker.Category TO 'game_developer_role';
GRANT INSERT, UPDATE, DELETE ON game_tracker.Platform TO 'game_developer_role';
GRANT INSERT, UPDATE, DELETE ON game_tracker.Game_Developer TO 'game_developer_role';
GRANT INSERT, UPDATE, DELETE ON game_tracker.Game_Publisher TO 'game_developer_role';
GRANT INSERT, UPDATE, DELETE ON game_tracker.Game_Genre TO 'game_developer_role';
GRANT INSERT, UPDATE, DELETE ON game_tracker.Game_Category TO 'game_developer_role';
GRANT INSERT, UPDATE, DELETE ON game_tracker.Game_Platform TO 'game_developer_role';
GRANT INSERT, UPDATE, DELETE ON game_tracker.Achievement TO 'game_developer_role';

-- 5) Example login accounts and initial passwords.
-- These are sample credentials for a local/demo setup only.
-- Replace passwords with unique secrets and restrict host values for your environment.
CREATE USER IF NOT EXISTS 'gamer_demo'@'localhost' IDENTIFIED BY 'gamer123';
CREATE USER IF NOT EXISTS 'admin_ops'@'localhost' IDENTIFIED BY 'admin123';
CREATE USER IF NOT EXISTS 'dev_studio'@'localhost' IDENTIFIED BY 'dev123';

GRANT 'gamer_role' TO 'gamer_demo'@'localhost';
GRANT 'admin_role' TO 'admin_ops'@'localhost';
GRANT 'game_developer_role' TO 'dev_studio'@'localhost';

-- Make each assigned role active automatically at login.
SET DEFAULT ROLE 'gamer_role' TO 'gamer_demo'@'localhost';
SET DEFAULT ROLE 'admin_role' TO 'admin_ops'@'localhost';
SET DEFAULT ROLE 'game_developer_role' TO 'dev_studio'@'localhost';

-- 6) Verify role grants after running:
SHOW GRANTS FOR 'gamer_demo'@'localhost';
SHOW GRANTS FOR 'admin_ops'@'localhost';
SHOW GRANTS FOR 'dev_studio'@'localhost';

-- Notes:
-- * MySQL accounts are database logins, not rows in the `User` application table.
-- * Existing `User` rows do not contain passwords. Do not store plaintext passwords there.
-- * The gamer role is intentionally read-only until user-specific writes are implemented
--   with ownership checks. Table-level grants cannot limit UPDATE/DELETE to only the
--   logged-in gamer's own rows.
-- * If connecting remotely, replace 'localhost' with a carefully restricted host/IP.
