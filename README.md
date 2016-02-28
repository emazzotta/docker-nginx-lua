# Nginx More Headers

A Docker project for a recent version of Nginx and the module "more_set_headers" to specify custom headers such as a server name like `1337-server` instead of `nginx` or `apache`
This also contains LuaJIT so that lua can be used in nginx configurations.

## Example

In your `nginx.conf`

```
http {
  ...
  more_set_headers 'Server: 1337-server';
  ...
}
```
