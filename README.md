# Annoyer

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `annoyer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:annoyer, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/annoyer](https://hexdocs.pm/annoyer).


# Idea: Authentication

* Extend Annoyence with "authentication"-Map
* Incomning can take authentication info from it's invokation and provide it in the annoyence
  * E.g.: Http Authentication-Header with either :bearer or :basic_username and :basic_password
* Add new macro/type "autenticate" to channels
  * If Authentication-prodivder is specified, auth is required for this channel
  * Method authenticate(annoyence) looks through the authentication-map to find something it supports
  * e.g. A specific OAuth2-Service (id.codeisland.org) would look for :token, verify the JWT
  * If Auth is good, add additional data to either authentication-map or meta
    * e.g. info from the verified JWT token
  * If Auth is bad or missing, return :missing or :expired or :invalid
* The incomming receives either an :ok or the auth-error and can react appropriately
  * e.g. HTTP could set the correct OAuth2 body and status-code

This would allow authenticated actions AND user-specific actions. For example, info could be pushed for a specific user by providing auth to the HTTP incoming on a specific topic. A channel could then check the auth, find a user-specific info (maybe in an external system/storage) such as a push-token send the result to a specific user via any outgoing.

# Idea: Persistence

* Add to Channel like transform
* Allows fetching like "fetchPersistent(topic, key, fallback)
* Allwos updating/setting/etz
* Could be just a Postgres DB with JSON column and value is alawys a Map.