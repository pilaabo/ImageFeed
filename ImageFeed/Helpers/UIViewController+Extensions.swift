import UIKit

extension UIViewController {
    func showErrorAlert(message: String) {
        showAlert(title: "Что-то пошло не так(", message: message)
    }

    func showAlert(
        title: String,
        message: String,
        actions: [UIAlertAction] = [UIAlertAction(title: "ОК", style: .default)]
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
}
