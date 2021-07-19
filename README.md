# kong-authz

[![GitHub Action](https://github.com/casbin-lua/kong-authz/workflows/test/badge.svg?branch=master)](https://github.com/casbin-lua/kong-authz/actions)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/casbin/lobby)

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

And install the kong-authz plugin by:
```
sudo luarocks install https://raw.githubusercontent.com/casbin-lua/kong-authz/master/kong-authz-0.0.1-1.rockspec
```

Finally, add this plugin's name to your kong.conf file by appending `kong-authz` (with a comma) to the `plugins` variable.

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

## Development

Want to customize this according to your scenario? Then navigate to your kong/plugins folder and do this:
```
git clone https://github.com/casbin-lua/kong-authz
cd kong-authz
# customize it here
luarocks make *.rockspec
```

## Documentation

The authorization determines a request based on `{subject, object, action}`, which means what `subject` can perform what `action` on what `object`. In this plugin, the meanings are:
1. `subject`: the logged-in username as passed in the header
2. `object`: the URL path for the web resource like "dataset1/item1"
3. `action`: HTTP method like GET, POST, PUT, DELETE, or the high-level actions you defined like "read-file", "write-blog"
For how to write authorization policy and other details, please refer to the [Casbin's documentation](https://casbin.org/).

## Example

An example of policy file and model file is given in the [examples](https://github.com/casbin-lua/kong-authz/tree/master/examples) directory of this repo. To use that for some service, clone the examples directory to your system and send a POST command to the Kong Admin API as:
```
curl -i -X POST \
  --url http://localhost:8001/services/example-service/plugins/ \
  --data 'name=kong-authz' \
  --data 'config.model_path=path_of_your_authz_model.conf' \
  --data 'config.policy_path=path_of_your_authz_policy.csv' \
  --data 'config.username=user'
```

This will configure the model and policy for *example-service*. Now, send a request for the first time with your configured config.username paramter through a header. For example:
```
curl -i -X GET \
  --url http://localhost:8000/ \
  --header 'user: anonymous' 
```
When run for the first time, it will create a Casbin Enforcer using the model path and policy path. If this returns any non 500 error, then the configuration is good to go otherwise please check the error.log file in your Kong setup.

## Getting Help

- [Casbin](https://casbin.org/)
- [Lua Casbin](https://github.com/casbin/lua-casbin/)

## License

This project is under the Apache 2.0 License.