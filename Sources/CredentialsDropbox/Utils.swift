// Adapted from https://github.com/IBM-Swift/Kitura-CredentialsGoogle

import Credentials

func createUserProfile(from dropboxData: [String:Any], for provider: String) -> UserProfile? {
    if let id = dropboxData["account_id"] as? String {
        var userEmails: [UserProfile.UserProfileEmail]? = nil
        if let email = dropboxData["email"] as? String {
            let userEmail = UserProfile.UserProfileEmail(value: email, type: "")
            userEmails = [userEmail]
        }
        
        var userName: UserProfile.UserProfileName? = nil
        var displayName = ""
        
        if let name = dropboxData["name"] as? [String:String] {
            if let dName = name["display_name"] {
                displayName = dName
            }
            
            if let givenName = name["given_name"],
                let familyName = name["surname"] {
                userName = UserProfile.UserProfileName(familyName: familyName, givenName: givenName, middleName: "")
            }
        }
        
        var userPhotos: [UserProfile.UserProfilePhoto]? = nil
        if let photo = dropboxData["profile_photo_url"] as? String {
            let userPhoto = UserProfile.UserProfilePhoto(photo)
            userPhotos = [userPhoto]
        }
        
        return UserProfile(id: id, displayName: displayName, provider: provider, name: userName, emails: userEmails, photos: userPhotos)
    }
    return nil
}

/* Example:
{
    "account_id": "dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc",
    "name": {
        "given_name": "Franz",
        "surname": "Ferdinand",
        "familiar_name": "Franz",
        "display_name": "Franz Ferdinand (Personal)",
        "abbreviated_name": "FF"
    },
    "email": "franz@dropbox.com",
    "email_verified": true,
    "disabled": false,
    "is_teammate": false,
    "profile_photo_url": "https://dl-web.dropbox.com/account_photo/get/dbid%3AAAH4f99T0taONIb-OurWxbNQ6ywGRopQngc?vers=1453416696524\u0026size=128x128"
}
*/
