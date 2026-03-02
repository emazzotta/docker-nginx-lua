[![Build Status](https://github.com/emazzotta/docker-nginx-lua/workflows/build/badge.svg)](https://github.com/emazzotta/docker-nginx-lua/actions)
[![License](http://img.shields.io/:license-mit-blue.svg?style=flat)](https://emanuelemazzotta.com/mit-license)
[![Docker Pulls](https://img.shields.io/docker/pulls/emazzotta/docker-nginx-lua.svg?style=flat)](https://hub.docker.com/r/emazzotta/docker-nginx-lua/)

# Docker Nginx LuaJIT

Nginx compiled from source with [LuaJIT](https://github.com/openresty/luajit2), [lua-nginx-module](https://github.com/openresty/lua-nginx-module), [headers-more](https://github.com/openresty/headers-more-nginx-module), and [nginx_accept_language_module](https://github.com/giom/nginx_accept_language_module).

## Usage

```bash
docker run -v <my_conf_dir>:/etc/nginx/conf.d -p 80:80 emazzotta/docker-nginx-lua
```

Or with Docker Compose:

```bash
docker compose up
```

## Example

The `example/conf.d/default.conf` combines all modules in a single server block:

```nginx
server {
    listen 80;
    server_name _;

    location / {
        set_from_accept_language $lang en de fr;
        more_set_headers 'X-Detected-Language: $lang';

        default_type text/plain;
        content_by_lua_block {
            ngx.say("It works - docker-nginx-lua: OK [" .. ngx.var.lang .. "]")
        }
    }
}
```

Test it:

```bash
curl -H "Accept-Language: de" http://localhost:8080
# It works - docker-nginx-lua: OK [de]
# Header: X-Detected-Language: de
```

## Author

[Emanuele Mazzotta](mailto:hello@mazzotta.me)

## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Femazzotta%2Fdocker-nginx-lua.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Femazzotta%2Fdocker-nginx-lua?ref=badge_large)
