import UIKit

extension UIViewController {
    func showErrorAlert(
        title: String = "Что-то пошло не так",
        message: String,
        retryHandler: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let retryHandler {
            // TODO: Реализовать функциональные UIAlertAction
        } else {
            alert.addAction(UIAlertAction(title: "Ок", style: .default))
        }
        
        present(alert, animated: true)
    }
}
