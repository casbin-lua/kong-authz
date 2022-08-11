# kong-authz

[![GitHub Action](https://github.com/casbin-lua/kong-authz/workflows/test/badge.svg?branch=master)](https://github.com/casbin-lua/kong-authz/actions)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/casbin/lobby)

kong-authz is an authorization plugin for Kong based on [lua-casbin](https://github.com/casbin/lua-casbin/).

## Prerequisites

The following need to be installed in advance:

- [Kong](https://konghq.com/)
- [4daysorm-adapter](https://github.com/casbin-lua/4daysorm-adapter) (if you want to use database as policy storage by 4DaysORM-adatper)
- [luasql-adapter](https://github.com/casbin-lua/luasql-adapter)(if you want to use database as policy storage by luasql-adatper)

**Notice:** The Casbin policy is reading from a file by default. If you want to use Casbin policy from DB, just choose one from 4daysorm-adapter and luasql-adapter.

## Installation

Ensure you have Casbin's system dependencies installed by:

```
sudo apt install gcc libpcre3 libpcre3-dev
```

Install Casbin's latest release from LuaRocks by:

```bash
sudo luarocks install casbin
```

And install the kong-authz plugin by:

```bash
sudo luarocks install https://raw.githubusercontent.com/casbin-lua/kong-authz/master/kong-authz-0.0.1-1.rockspec
```

Then, add this plugin's name to your kong.conf file by appending `kong-authz` (with a comma) to the `plugins` variable, such as:

```conf
# kong.conf
plugins = bundled, kong-authz
```

Finally, start or restart your Kong:

```bash
kong start [-c /path/to/kong.conf]
```

## Configuration

You can add this plugin on top of any service/API or globally by sending a request through the Kong Admin API to the server. 

For example, add this plugin globally and specify a Policy storage mode:

```bash
# file
curl -i -X POST \
  --url http://localhost:8001/plugins/ \
  --data 'name=kong-authz' \
  --data 'config.model_path=/path/to/model_path.conf' \
  --data 'config.policy_path=/path/to/policy_path.csv' \
  --data 'config.username=user'
```

```bash
# luasql
curl -i -X POST \
  --url http://localhost:8001/services/example-service/plugins/ \
  --data 'name=kong-authz' \
  --data 'config.model_path=/mnt/kong/examples/authz_model.conf' \
  --data 'config.username=user' \
  --data 'config.adapter=luasql' \
  --data 'config.db_info.db_type=mysql' \
  --data 'config.db_info.database=casbin' \
  --data 'config.db_info.username=root' \
  --data 'config.db_info.password=********' \
  --data 'config.db_info.host=127.0.0.1' \
  --data 'config.db_info.port=3306'
```

```bash
# 4daysorm
curl -i -X POST \
  --url http://localhost:8001/services/example-service/plugins/ \
  --data 'name=kong-authz' \
  --data 'config.model_path=/mnt/kong/examples/authz_model.conf' \
  --data 'config.username=user' \
  --data 'config.adapter=4daysorm' \
  --data 'config.db_info.db_type=mysql' \
  --data 'config.db_info.database=casbin' \
  --data 'config.db_info.username=root' \
  --data 'config.db_info.password=********' \
  --data 'config.db_info.host=127.0.0.1' \
  --data 'config.db_info.port=3306'
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
<td><code>config.username</code><br><em>required</em></td>
<td>The username field from your headers, this will be used as the subject in the policy enforcement</td>
</tr>
<tr>
<td><code>config.adapter</code></td>
<td>The policy storage type: {"file", "luasql", "4daysorm"}, default is "file"</td>
</tr>
<tr>
<td><code>config.model_path</code><br><em>required</em></td>
<td>The system path of your Casbin model file</td>
</tr>
<tr>
<td><code>config.policy_path</code><br><em>conditional</em></td>
<td>The system path of your Casbin policy file, it needs to be configured only when the adapter is configured as "file"</td>
</tr>
<tr>
<td><code>config.db_info</code><br><em>conditional</em></td>
<td>The database connect info of your Casbin policy storage, it needs to be configured only when the adapter is configured as "luasql" or "4daysorm"
</td>
</tr>
<tr>
<td><code>config.db_info.db_type</code><br><em>conditional</em></td>
<td>config.db_info == "luasql: the database type: {"mysql", "postgres", "sqlite3"}<br />
    config.db_info == "4daysorm": the database type: {"mysql", "postgresql", "sqlite3"}
</td>
</tr>
<tr>
<td><code>config.db_info.database</code><br><em>conditional</em></td>
<td>The path to database file for "sqlite3". For other databases this value contains database name.
</td>
</tr>
<tr>
<td><code>config.db_info.username</code><br><em>conditional</em></td>
<td>The database username.
</td>
</tr>
<tr>
<td><code>config.db_info.password</code><br><em>conditional</em></td>
<td>The database password.
</td>
</tr>
<tr>
<td><code>config.db_info.host</code><br><em>conditional</em></td>
<td>The database host("sqlite3" does not need to configure this).
</td>
</tr>
<tr>
<td><code>config.db_info.port</code><br><em>conditional</em></td>
<td>The database port("sqlite3" does not need to configure this).
</td>
</tr>
</tbody></table>

If the request is authorized, the execution will proceed normally. While if it is not authorized, it will return "Access Denied" error with the 403 exit code and stop any further execution.

## Development

Want to customize this according to your scenario? Then navigate to your kong/plugins folder and do this:

```bash
git clone https://github.com/casbin-lua/kong-authz
cd kong-authz
# clear old kong-authz if existed
luarocks remove kong-authz
# customize it here
luarocks make *.rockspec
```

You can run this command to test your correctness:
```bash
busted plugin_test.lua
```

## Documentation

The authorization determines a request based on `{subject, object, action}`, which means what `subject` can perform what `action` on what `object`. In this plugin, the meanings are:

1. `subject`: the logged-in username as passed in the header
2. `object`: the URL path for the web resource like "dataset1/item1"
3. `action`: HTTP method like GET, POST, PUT, DELETE, or the high-level actions you defined like "read-file", "write-blog"
   For how to write authorization policy and other details, please refer to the [Casbin's documentation](https://casbin.org/).

## Example

An example of policy file and model file is given in the [examples](https://github.com/casbin-lua/kong-authz/tree/master/examples) directory of this repo. To use that for some service, clone the examples directory to your system and send a POST command to the Kong Admin API as:

```bash
# set up an example service
curl -i -X POST \
--url http://localhost:8001/services/ \
--data 'name=example-service' \
--data 'url=http://mockbin.org'
# set up an example route
curl -i -X POST \
--url http://localhost:8001/services/example-service/routes \
--data 'hosts[]=example.com'
```

```bash
curl -i -X POST \
  --url http://localhost:8001/services/example-service/plugins/ \
  --data 'name=kong-authz' \
  --data 'config.model_path=path_of_your_authz_model.conf' \
  --data 'config.policy_path=path_of_your_authz_policy.csv' \
  --data 'config.username=user'
```

This will configure the model and policy for *example-service*. Now, send a request for the first time with your configured config.username paramter through a header. For example:

```bash
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