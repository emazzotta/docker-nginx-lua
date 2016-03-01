# Docker Nginx More Headers + Lua

A Docker project for a recent version of Nginx and the module `more_set_headers` to specify custom headers such as a server name like `1337-server` instead of `nginx` or `apache`.
This also contains LuaJIT so that lua can be used in nginx configurations.

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

In your site configuration for automatic language based redirecting.

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

## Author

[Emanuele Mazzotta](mailto:hello@mazzotta.me?subject=Docker Nginx More Headers + Lua)

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).
