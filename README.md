[![Build Status](https://github.com/emazzotta/docker-nginx-lua/workflows/Docker%20Build%20&%20Push/badge.svg)](https://github.com/emazzotta/docker-nginx-lua/actions)
[![License](http://img.shields.io/:license-mit-blue.svg?style=flat)](https://emanuelemazzotta.com/mit-license)
[![Docker Pulls](https://img.shields.io/docker/pulls/emazzotta/docker-nginx-lua.svg?style=flat)](https://hub.docker.com/r/emazzotta/docker-nginx-lua/)

# Docker Nginx

A Docker project for a recent version of the Nginx webserver and the module `more_set_headers` to specify custom headers such as a server name like `1337-server` instead of `nginx` or `apache`.
Another module this nginx build contains is [Google's ngx_pagespeed module](https://github.com/pagespeed/ngx_pagespeed)

## Usage

```bash
docker run -v <my_conf_dir>:/etc/nginx/conf.d -v /var/ngx_pagespeed_cache -p 80:80 emazzotta/docker-nginx-lua
```

## Note

While this project is called "docker-nginx-lua" I've dropped the support for LuaJit, see https://github.com/emazzotta/docker-nginx-lua/issues/3

## Examples

### More Set Headers

```
http {
    ...
    more_set_headers 'Server: 1337-server';
    ...
}
```

### Accept Language Module

```
server {   
    ...
    location ~ / {
        set_from_accept_language $lang en de;
        if ( $request_uri ~ ^/$  ) {
            rewrite ^/$ /$lang redirect;
            break;
        }
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
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Femazzotta%2Fdocker-nginx-lua.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Femazzotta%2Fdocker-nginx-lua?ref=badge_large)

