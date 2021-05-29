# Request

A lightweight and typesafe wrapper around `URLSession`'s `URLRequest` data publisher API. 

Some notable features:
- Case insensitive header fields.
- Composable and reusable `URL` building.


## Example

Start by defining a resuable environment. 

    extension Request.Environment {
        
        static var pnut: Self {
            .init(host: "api.pnut.io", path: "/v1")
        }
    }

Then build a request.

    let global = Request(to: .pnut, path: "/posts/stream/global")

    let globalPosts = global
        .publisher()
        .map(\.data)
        .decode(type: Response<Post>.self, decoder: JSONDecoder.pnut)

Lets send some data, in this case, to [an authentication endpoint](https://pnut.io/docs/authentication/password-flow). Heres how to model the required values.

    enum PasswordAuthorizationKey: String, Hashable, QueryItem {
        case clientID = "client_id"
        case passwordGrantSecret = "password_grant_secret"
        case username, password
        case grantType = "grant_type"
        case scope
    }

Encoding the data is simplified by conforming to `QueryItem` and using `String` values.

    let payload: [PasswordAuthorizationKey: String] = [
        .clientID: "913z4jqpnqfn5m90ksf0",
        .passwordGrantSecret: "sfhhsjhhfkddonnfjfloookffheheerrre",
        .username: "shawn", .password: "*******",
        .grantType: "password",
        .scope: "basic,write_post"
    ]

    let auth = Request(to: .pnut, method: .post, path: "/oauth/access_token", body: .urlEncoded(payload))


## Contact

This is meant to be my personal, lightweight, and type-safe networking library. That being said, feedback is welcome and if you find it useful please let me know. I'm [@shawn](http://pnut.io/@shawn) on [pnut.io](http://pnut.io) and [@shawnthroop](http://twitter.com/shawnthroop) most other places.
