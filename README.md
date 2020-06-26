# Annoyer

Transports Annoyences (= Events) from one system to another, making in-flight changes to it.

# Specification

**Note:** This is a work-in-progress and will be updated sporadically!

## Transforms

1. A Transform must receive a _single_ Annyoence to work with.
2. A Transform may return a new and altered Annoyence.
3. A Transform may return the Annoyence without making any changes to it. There is no special indication for this case.
4. A Transform may drop the Annoyence to remove it from further processing by the Channel.
5. A Transform must drop the Annoyence if it can't complete it's job and there is no suitable fallback.
    * When building Channels, this specifically allows users to depend on a Transform having done it's job as expected and subsequent Transforms to not be called with invalid/unexpected Annoyences.

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