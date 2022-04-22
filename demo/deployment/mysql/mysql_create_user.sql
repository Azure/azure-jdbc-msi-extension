SET aad_auth_validate_oids_in_tenant = OFF;

DROP USER '%%login_name%%'@'%';

CREATE AADUSER '%%login_name%%' IDENTIFIED BY '%%user_id%%';
grant all privileges on Db.* to '%%login_name%%'@'%';

FLUSH privileges;