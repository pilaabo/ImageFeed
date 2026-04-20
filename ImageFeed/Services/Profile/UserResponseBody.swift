struct UserResponseBody: Decodable {
    struct ProfileImage: Decodable { let small: String }

    let profileImage: ProfileImage
}
