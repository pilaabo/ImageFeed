struct ProfileResponseBody: Decodable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}
