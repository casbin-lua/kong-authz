--Copyright 2021 The casbin Authors. All Rights Reserved.
--
--Licensed under the Apache License, Version 2.0 (the "License");
--you may not use this file except in compliance with the License.
--You may obtain a copy of the License at
--
--    http://www.apache.org/licenses/LICENSE-2.0
--
--Unless required by applicable law or agreed to in writing, software
--distributed under the License is distributed on an "AS IS" BASIS,
--WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--See the License for the specific language governing permissions and
--limitations under the License.

local Enforcer = require("casbin")
local get_headers = ngx.req.get_headers
local kong_response = kong.response

local plugin = {
    PRIORITY = 1000,
    VERSION = "0.1",
}

_G.DB = {} -- required if using 4DaysORMAdapter

local getLuaSQLAdapter = function (db_info)
    local Adapter = require("casbin."..db_info.db_type)
    if db_info.db_type == "sqlite3" then
        return Adapter:new(db_info.database, db_info.username, db_info.password)
    end
    return Adapter:new(db_info.database, db_info.username, db_info.password, db_info.host, db_info.port)
end

local get4DaysORMAdapter = function (db_info)
    DB.type = db_info.db_type
    DB.name = db_info.database
    DB.username = db_info.username
    DB.password = db_info.password
    DB.new = true
    if db_info.db_type ~= SQLITE then
        DB.host = db_info.host
        DB.port = db_info.port
    end
    local Adapter = require("CasbinORMAdapter")
    return Adapter:new()
end

local getEnforcer = function (conf)
    local adapterType = conf.adapter
    if adapterType == "file" then
        return Enforcer:new(conf.model_path, conf.policy_path)
    elseif adapterType == "luasql" then
        local adapter = getLuaSQLAdapter(conf.db_info)
        return Enforcer:new(conf.model_path, adapter)
    elseif adapterType == "4daysorm" then
        local adapter = get4DaysORMAdapter(conf.db_info)
        return Enforcer:new(conf.model_path, adapter)
    end
end

function plugin:access(conf)
    -- creates an enforcer when request sent for the first time
    if not self.e then
        self.e = getEnforcer(conf)
    end

    local path = ngx.var.request_uri
    local method = ngx.var.request_method
    local username = get_headers()[conf.username]

    if path and method and username then
        if not self.e:enforce(username, path, method) then
            return kong_response.exit(403, "Access denied")
        end
    else
        return kong_response.exit(403, "Access denied")
    end
end

return plugin