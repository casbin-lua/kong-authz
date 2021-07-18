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

function plugin:access(conf)
    -- creates an enforcer when request sent for the first time
    if not self.e then
        self.e = Enforcer:new(conf.model_path, conf.policy_path)
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