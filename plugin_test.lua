local http = require("socket.http")

local function isAuthorized(page, username, HTTPMethod)
    local headers = {
        ["user"] = username,
        ["host"] = "example.com"
    }
    local _, code, _, _ = http.request{url = "http://127.0.0.1:8000" .. page, headers = headers, method = HTTPMethod}
    if code == 403 then
        return false
    else
        return true
    end
end

describe("Plugin Tests", function ()
    it("Homepage Tests", function ()
        assert.is.True(isAuthorized("/", "anonymous", "GET"))
        assert.is.True(isAuthorized("/", "alice", "GET"))
        assert.is.False(isAuthorized("/", "anonymous", "POST"))
        assert.is.True(isAuthorized("/", "alice", "POST"))
        assert.is.True(isAuthorized("/", "alice", "PUT"))
    end)

    it("Resource Tests", function ()
        assert.is.False(isAuthorized("/resource1", "anonymous", "GET"))
        assert.is.True(isAuthorized("/resource1", "alice", "GET"))
        assert.is.False(isAuthorized("/resource1", "anonymous", "POST"))
        assert.is.True(isAuthorized("/resource1", "alice", "POST"))
        assert.is.False(isAuthorized("/dataset1/res1", "anonymous", "GET"))
        assert.is.True(isAuthorized("/dataset1/res1", "alice", "GET"))
    end)

    it("RBAC Tests", function ()
        assert.is.True(isAuthorized("/", "admin", "GET"))
        assert.is.True(isAuthorized("/", "alice", "GET"))
        assert.is.True(isAuthorized("/res", "admin", "POST"))
        assert.is.True(isAuthorized("/res", "alice", "POST"))
    end)
end)