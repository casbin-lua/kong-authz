local dirver = require("luasql.mysql")

-- create env
local env = dirver.mysql()

local database = os.getenv("MYSQL_DB") or "casbin"
local user = os.getenv("MYSQL_USER") or "root"
local password = os.getenv("MYSQL_PASSWORD") or "root"

-- connect mysql
local conn, err = env:connect(database, user, password, "127.0.0.1", "3306")

if err then
  error("Could not create connection to database, error:" .. err)
end

-- set DB decode
conn:execute "SET NAMES UTF8"

local initSQL =
  [[
CREATE TABLE IF NOT EXISTS `casbin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `v0` varchar(255) DEFAULT NULL,
  `v1` varchar(255) DEFAULT NULL,
  `v2` varchar(255) DEFAULT NULL,
  `v3` varchar(255) DEFAULT NULL,
  `v5` varchar(255) DEFAULT NULL,
  `v4` varchar(255) DEFAULT NULL,
  `ptype` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
)
]]

-- 4daysorm content
local ormSQL =
  [[
    INSERT INTO `casbin` VALUES (1,'*','/','GET',NULL,NULL,NULL,'p'),(2,'admin','*','*',NULL,NULL,NULL,'p'),(3,'alice','admin',NULL,NULL,NULL,NULL,'g')
]]

conn:execute(initSQL)
-- execute database action
conn:execute(ormSQL)

local all = conn:execute("select * from casbin")
local row = all:fetch({}, "a")

while row do
  local var = string.format("%d %s %s %s %s\n", row.id, row.ptype, row.v0, row.v1, tostring(row.v2))

  print(var)

  row = all:fetch(row, "a")
end

conn:close() -- close database connect
env:close() -- close database env
