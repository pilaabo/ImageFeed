import UIKit

extension UIViewController {
    func showErrorAlert(
        title: String = "Что-то пошло не так(",
        message: String,
        actions: [UIAlertAction] = [UIAlertAction(title: "ОК", style: .default)]
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
}
