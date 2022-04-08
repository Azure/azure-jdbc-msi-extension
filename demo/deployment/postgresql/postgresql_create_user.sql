SET aad_validate_oids_in_tenant = off;
CREATE ROLE "%%login_name%%" WITH LOGIN PASSWORD '%%user_id%%' IN ROLE azure_ad_user;

GRANT ALL PRIVILEGES ON DATABASE "%%dbname%%" TO "%%login_name%%";