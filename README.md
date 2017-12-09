# CredentialsDropbox
Plugin for the Kitura-Credentials framework that authenticates using a Dropbox OAuth2 token

## Summary
Plugin for [Kitura-Credentials](https://github.com/IBM-Swift/Kitura-Credentials) framework that authenticates using a [Dropbox OAuth2 token](https://www.dropbox.com/developers/reference/oauth-guide) that was acquired by a mobile app or other client of the Kitura based backend.

## Table of Contents
* [Swift version](#swift-version)
* [Example of authentication with a Dropbox OAuth2 token](#example-of-authentication-with-a-dropbox-oauth2-token)
* [License](#license)

## Swift version
The latest version of CredentialsDropbox requires **Swift 4.0**. You can download this version of the Swift binaries by following this [link](https://swift.org/download/). Compatibility with other Swift versions is not guaranteed.

## Example of authentication with a Dropbox OAuth2 token

This example shows how to use `CredentialsDropboxToken` plugin to authenticate post requests, it shows both the server side and the client side of the request involved.

### Server side

First create an instance of `Credentials` and an instance of `CredentialsDropboxToken` plugin:

```swift
import Credentials
import CredentialsDropbox

let credentials = Credentials()
let dropboxCredentials = CredentialsDropboxToken(options: options)
```
**Where:**
- *options* is an optional dictionary ([String:Any]) of Dropbox authentication options whose keys are listed in `CredentialsDropboxOptions`.

Now register the plugin:
```swift
credentials.register(dropboxCredentials)
```

Connect `credentials` middleware to post requests:

```swift
router.post("/collection/:new", middleware: credentials)
```
If the authentication is successful, `request.userProfile` will contain user profile information received from Dropbox:
```swift
router.post("/collection/:new") {request, response, next in
  ...
  let profile = request.userProfile
  let userId = profile.id
  let userName = profile.displayName
  ...
  next()
}
```

### Client side
The client needs to put a [Dropbox access token](https://www.dropbox.com/developers/reference/oauth-guide) in the request's `access_token` HTTP header field, and "DropboxToken" in the `X-token-type` field. And because Dropbox apparently doesn't have a direct means to validate an access token, you need to pass the dropbox `uid` with the header key `X-account-id`:

```swift
let urlRequest = NSMutableURLRequest(URL: NSURL(string: "http://\(serverUrl)/collection/\(name)"))
urlRequest.HTTPMethod = "POST"
urlRequest.HTTPBody = ...

urlRequest.addValue(dropboxAccessToken, forHTTPHeaderField: "access_token")
urlRequest.addValue("DropboxToken", forHTTPHeaderField: "X-token-type")
urlRequest.addValue(dropboxUid, forHTTPHeaderField: "X-account-id")
Alamofire.request(urlRequest).responseJSON {response in
  ...
}

```

## License
This library is licensed under MIT. Full license text is available in [LICENSE](LICENSE).
