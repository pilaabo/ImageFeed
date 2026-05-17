import UIKit

extension UIViewController {
    /// Алерт ошибки с типовым заголовком и одной кнопкой «ОК».
    func showErrorAlert(message: String) {
        showAlert(title: "Что-то пошло не так(", message: message)
    }

    /// Универсальный алерт. По умолчанию показывает одну кнопку «ОК»;
    /// для confirmation-диалогов передайте свой набор UIAlertAction.
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
