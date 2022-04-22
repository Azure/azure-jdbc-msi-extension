SET aad_validate_oids_in_tenant = off;

REVOKE ALL PRIVILEGES ON DATABASE "%%dbname%%" FROM "%%login_name%%";

DROP USER IF EXISTS "%%login_name%%";

CREATE ROLE "%%login_name%%" WITH LOGIN PASSWORD '%%user_id%%' IN ROLE azure_ad_user;

GRANT ALL PRIVILEGES ON DATABASE "%%dbname%%" TO "%%login_name%%";