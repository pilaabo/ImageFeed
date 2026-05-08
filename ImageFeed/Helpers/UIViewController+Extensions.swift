import UIKit

extension UIViewController {
    func showErrorAlert(
        title: String = "Что-то пошло не так(",
        message: String
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}
