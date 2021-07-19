package = "kong-authz"
version = "0.0.1-1"
source = {
   url = "git://github.com/casbin-lua/kong-authz",
}
description = {
   summary = "Casbin authorization plugin for Kong",
   detailed = [[
      kong-authz is an authorization plugin for Kong, based on lua-casbin.
   ]],
   detailed = "kong-authz is an authorization plugin for Kong, based on lua-casbin.",
   homepage = "https://github.com/casbin-lua/kong-authz",
   license = "Apache License 2.0",
   maintainer = "admin@casbin.org"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      ["kong.plugins.kong-authz.handler"] = "src/handler.lua",
      ["kong.plugins.kong-authz.schema"] = "src/schema.lua"
   }
}
