enum Constants {
    static let accessKey                  = "AD3mth0JjFP4_HSz59cknghLFx5MHnVAlQxEaCIbvwg"
    static let secretKey                  = "4Hd6rAavk-ZRIp5jD81CaxQFaeBVkgvDriLU0VUEf90"
    static let redirectURI                = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope                = "public+read_user+write_likes"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let defaultBaseURLString       = "https://api.unsplash.com"
    static let photosPerPage              = 10
}

struct AuthConfiguration {
    static let standard = AuthConfiguration(
        accessKey: Constants.accessKey,
        secretKey: Constants.secretKey,
        redirectURI: Constants.redirectURI,
        accessScope: Constants.accessScope,
        unsplashAuthorizeURLString: Constants.unsplashAuthorizeURLString,
        defaultBaseURLString: Constants.defaultBaseURLString,
        photosPerPage: Constants.photosPerPage
    )

    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let unsplashAuthorizeURLString: String
    let defaultBaseURLString: String
    let photosPerPage: Int

    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        unsplashAuthorizeURLString: String,
        defaultBaseURLString: String,
        photosPerPage: Int
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.unsplashAuthorizeURLString = unsplashAuthorizeURLString
        self.defaultBaseURLString = defaultBaseURLString
        self.photosPerPage = photosPerPage
    }
}
