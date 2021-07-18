# kong-authz

kong-authz is an authorization plugin for Kong based on [lua-casbin](https://github.com/casbin/lua-casbin/).

## Installation

Ensure you have Casbin's system dependencies installed by:
```
sudo apt install gcc libpcre3 libpcre3-dev
```

Install Casbin's latest release (currently v1.16.1) from LuaRocks by:
```
sudo luarocks install https://raw.githubusercontent.com/casbin/lua-casbin/master/casbin-1.16.1-1.rockspec
```

And finally install the kong-authz plugin by:
```
sudo luarocks install https://raw.githubusercontent.com/casbin-lua/kong-authz/master/kong-authz-0.0.1-1.rockspec
```

## Configuration

You can add this plugin on top of any service/API or globally by sending a request through the Kong Admin API to the server. For example, for adding this plugin globally:
```
curl -i -X POST \
  --url http://localhost:8001/plugins/ \
  --data 'name=kong-authz' \
  --data 'config.model_path=/path/to/model_path.conf' \
  --data 'config.policy_path=/path/to/policy_path.csv' \
  --data 'config.username=user'
```
<table><thead>
<tr>
<th>Parameter</th>
<th>Description</th>
</tr>
</thead><tbody>
<tr>
<td><code>name</code></td>
<td>The name of the plugin which is: <code>kong-authz</code></td>
</tr>
<tr>
<td><code>config.model_path</code><br><em>required</em></td>
<td>The system path of your Casbin model file</td>
</tr>
<tr>
<td><code>config.policy_path</code><br><em>required</em></td>
<td>The system path of your Casbin policy file</td>
</tr>
<td><code>config.username</code><br><em>required</em></td>
<td>The username field from your headers, this will be used as the subject in the policy enforcement</td>
</tr>
</tbody></table>

If the request is authorized, the execution will proceed normally. While if it is not authorized, it will return "Access Denied" error with the 403 exit code and stop any further execution.

## Documentation

The authorization determines a request based on `{subject, object, action}`, which means what `subject` can perform what `action` on what `object`. In this plugin, the meanings are:
1. `subject`: the logged-in username as passed in the header
2. `object`: the URL path for the web resource like "dataset1/item1"
3. `action`: HTTP method like GET, POST, PUT, DELETE, or the high-level actions you defined like "read-file", "write-blog"
For how to write authorization policy and other details, please refer to the [Casbin's documentation](https://casbin.org/).

## Getting Help

- [Casbin](https://casbin.org/)
- [Lua Casbin](https://github.com/casbin/lua-casbin/)

## License

This project is under the Apache 2.0 License.