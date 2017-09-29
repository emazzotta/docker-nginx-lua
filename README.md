[![License](http://img.shields.io/:license-mit-brightgreen.svg?style=flat)](http://doge.mit-license.org)
[![Docker Pulls](https://img.shields.io/docker/pulls/emazzotta/docker-nginx-more-headers-lua.svg?style=flat)](https://hub.docker.com/r/emazzotta/docker-nginx-more-headers-lua/)
[![Docker Layers](https://images.microbadger.com/badges/image/emazzotta/docker-nginx-more-headers-lua.svg?style=flat)](https://microbadger.com/images/emazzotta/docker-nginx-more-headers-lua "Microbadger Docker Layers")

# Docker Nginx More Headers + Lua

A Docker project for a recent version of the Nginx webserver and the module `more_set_headers` to specify custom headers such as a server name like `1337-server` instead of `nginx` or `apache`.
This also contains LuaJIT so that lua can be used in nginx configurations.
Another thing that this nginx build contains is [Google's ngx_pagespeed module](https://github.com/pagespeed/ngx_pagespeed)

Link to Dockerhub: https://hub.docker.com/r/emazzotta/docker-nginx-more-headers-lua/

## Examples

### More Set Headers

In your `nginx.conf`.

```
http {
    ...
    more_set_headers 'Server: 1337-server';
    ...
}
```

### Lua

In your site configuration e.g. for automatic language based redirecting.

```
server {   
    ...
    location ~ / {
        rewrite_by_lua '
        for lang in (ngx.var.http_accept_language .. ","):gmatch("([^,]*),") do
            if string.sub(lang, 0, 2) == "en" then
                ngx.redirect("/en/")
            end
            if string.sub(lang, 0, 2) == "de" then
                ngx.redirect("/de/")
            end
        end
        ngx.redirect("/en/")';
    }
    ...
}
```

### Pagespeed

```
server {
    ...
    pagespeed on;
    pagespeed FileCachePath /var/cache/nginx;
    pagespeed XHeaderValue "Pagespeed";
    pagespeed RewriteLevel CoreFilters;
    ...
}
```

## Author

[Emanuele Mazzotta](mailto:hello@mazzotta.me)

## License

[MIT License](LICENSE.md) © Emanuele Mazzotta

