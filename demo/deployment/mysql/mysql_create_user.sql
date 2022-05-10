-- To grant database privileges to "%%login_name%%"
SET aad_auth_validate_oids_in_tenant = OFF;

DROP USER IF EXISTS '%%login_name%%'@'%';

CREATE AADUSER '%%login_name%%' IDENTIFIED BY '%%user_id%%';

GRANT ALL PRIVILEGES ON Db.* TO '%%login_name%%'@'%';

FLUSH privileges;
--