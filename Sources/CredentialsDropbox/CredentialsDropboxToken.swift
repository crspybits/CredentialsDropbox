// Adapted from https://github.com/IBM-Swift/Kitura-CredentialsGoogle

import Kitura
import KituraNet
import LoggerAPI
import Credentials

import Foundation

// MARK CredentialsDropboxToken

/// Authentication using Dropbox OAuth2 token.
public class CredentialsDropboxToken: CredentialsPluginProtocol {
    
    /// The name of the plugin.
    public var name: String {
        return "DropboxToken"
    }
    
    /// An indication as to whether the plugin is redirecting or not.
    public var redirecting: Bool {
        return false
    }

    private var delegate: UserProfileDelegate?
    
    /// A delegate for `UserProfile` manipulation.
    public var userProfileDelegate: UserProfileDelegate? {
        return delegate
    }
    
    /// Initialize a `CredentialsGoogleDropbox` instance.
    ///
    /// - Parameter options: A dictionary of plugin specific options. The keys are defined in `CredentialsGoogleOptions`.
    public init(options: [String:Any]?=nil) {
        delegate = options?[CredentialsDropboxOptions.userProfileDelegate] as? UserProfileDelegate
    }
    
    /// User profile cache.
    public var usersCache: NSCache<NSString, BaseCacheElement>?
    
    /// Authenticate incoming request using Dropbox OAuth2 token.
    ///
    /// - Parameter request: The `RouterRequest` object used to get information
    ///                     about the request.
    /// - Parameter response: The `RouterResponse` object used to respond to the
    ///                       request.
    /// - Parameter options: The dictionary of plugin specific options.
    /// - Parameter onSuccess: The closure to invoke in the case of successful authentication.
    /// - Parameter onFailure: The closure to invoke in the case of an authentication failure.
    /// - Parameter onPass: The closure to invoke when the plugin doesn't recognize the
    ///                     authentication token in the request.
    /// - Parameter inProgress: The closure to invoke to cause a redirect to the login page in the
    ///                     case of redirecting authentication.
    public func authenticate(request: RouterRequest, response: RouterResponse,
                             options: [String:Any], onSuccess: @escaping (UserProfile) -> Void,
                             onFailure: @escaping (HTTPStatusCode?, [String:String]?) -> Void,
                             onPass: @escaping (HTTPStatusCode?, [String:String]?) -> Void,
                             inProgress: @escaping () -> Void) {
        if let type = request.headers["X-token-type"], type == name {
            if let token = request.headers["access_token"],
                let accountId = request.headers["X-account-id"] {
                #if os(Linux)
                    let key = NSString(string: token)
                #else
                    let key = token as NSString
                #endif
                let cacheElement = usersCache!.object(forKey: key)
                if let cached = cacheElement {
                    onSuccess(cached.userProfile)
                    return
                }
                
                // See https://www.dropbox.com/developers/documentation/http/documentation#users-get_account and https://github.com/kunalvarma05/dropbox-php-sdk/issues/76
                
                var requestOptions: [ClientRequest.Options] = []
                requestOptions.append(.schema("https://"))
                requestOptions.append(.hostname("api.dropboxapi.com"))
                requestOptions.append(.method("POST"))
                requestOptions.append(.path("/2/users/get_account"))

                let dataToSend = [
                    "account_id": accountId
                ]
 
                var body:Data!
                do {
                    body = try JSONSerialization.data(withJSONObject: dataToSend)
                } catch (let error) {
                    Log.error("Failed to serialize dataToSend: \(error)")
                    onFailure(nil, nil)
                    return
                }

                var headers = [String:String]()
                let jsonMimeType = "application/json"
                headers["Accept"] = jsonMimeType
                headers["Content-Type"] = jsonMimeType
                headers["Authorization"] = "Bearer \(token)"
                requestOptions.append(.headers(headers))
                
                let req = HTTP.request(requestOptions) { response in
                    if let response = response, response.statusCode == HTTPStatusCode.OK {
                        do {
                            var body = Data()
                            try response.readAllData(into: &body)

                            if let dictionary = try JSONSerialization.jsonObject(with: body, options: []) as? [String : Any],
                                let userProfile = createUserProfile(from: dictionary, for: self.name) {
                                if let delegate = self.delegate ?? options[CredentialsDropboxOptions.userProfileDelegate] as? UserProfileDelegate {
                                    delegate.update(userProfile: userProfile, from: dictionary)
                                }

                                let newCacheElement = BaseCacheElement(profile: userProfile)
                                #if os(Linux)
                                    let key = NSString(string: token)
                                #else
                                    let key = token as NSString
                                #endif
                                self.usersCache!.setObject(newCacheElement, forKey: key)
                                onSuccess(userProfile)
                                return
                            }
                        } catch {
                            Log.error("Failed to read Dropbox response")
                        }
                    }
                    onFailure(nil, nil)
                }
                req.write(from: body)
                req.end()
            }
            else {
                onFailure(nil, nil)
            }
        }
        else {
            onPass(nil, nil)
        }
    }
}
