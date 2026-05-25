import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()

        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {
            preconditionFailure("Unable to instantiate ImagesListViewController from storyboard")
        }
        imagesListViewController.configure(ImagesListPresenter())
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )

        let profileViewController = ProfileViewController()
        profileViewController.configure(ProfilePresenter())
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )

        viewControllers = [imagesListViewController, profileViewController]
    }
}
