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

local typedefs = require "kong.db.schema.typedefs"

local adapter_type_arr = {"file", "luasql", "4daysorm"}
local db_type_arr = {"mysql", "postgres", "postgresql", "sqlite3"}
local luasql_arr = {"mysql", "postgres", "sqlite3"}
local orm_arr = {"mysql", "postgresql", "sqlite3"}

-- judge str not empty: not nil && ~= ''
local function isNotEmptyStr(str)
    return str and (string.len(tostring(str)) > 0)
end

-- judge if an array contains an element
local function contains(ele, arr)
    for _, value in pairs(arr) do
        if ele == value then
          return true
        end
    end
    return false
end

return {
    name = "kong-authz",
    fields = {
        {consumer = typedefs.no_consumer},
        {protocols = typedefs.protocols_http},
        {config = {
            type = "record",
            fields = {
                {model_path = {required = true, type = "string"}},
                {policy_path = {type = "string"}},
                {username = {required = true, type = "string"}},
                {adapter = {type = "string", one_of = adapter_type_arr, default = "file"}},
                {db_info = {
                    type = "record",
                    fields = {
                        {db_type = {type = "string", one_of = db_type_arr}},
                        {database = {type = "string"}},
                        {username = {type = "string"}},
                        {password = {type = "string"}},
                        {host = {type = "string"}},
                        {port = {type = "string"}}
                    }
                }}
            },
            custom_validator = function (config)
                local adapter_type = config.adapter
                if adapter_type == "file" then
                    if isNotEmptyStr(config.policy_path) then
                        return true
                    end
                    return false, "default use FileAdapter, you should specify model_path and policy_path"
                end
                local db_type = config.db_info.db_type
                if not isNotEmptyStr(db_type) then
                    return false, "you are using sql-adapter, please specify db_type and other required db info"
                end
                if adapter_type == "luasql" and (not contains(db_type, luasql_arr)) then
                    return false, db_type .. " not supported when adapter_type is " .. adapter_type
                elseif adapter_type == "4daysorm" and (not contains(db_type, orm_arr)) then
                    return false, db_type .. " not supported when adapter_type is " .. adapter_type
                end
                return true
          end
        }}
    }
}