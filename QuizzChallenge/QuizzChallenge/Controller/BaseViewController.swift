import UIKit

class BaseViewController: UIViewController {

    @objc
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func addAlert(title: String? = nil, message: String? = nil, actionOkTitle: String? = nil, actionOkHandler: ((UIAlertAction) -> Void)? = nil, actionCancelTitle: String? = nil, actionCancelHandler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if let title = actionOkTitle {
                let actionOk: UIAlertAction = UIAlertAction(title: title, style: .default, handler: actionOkHandler)
                alert.addAction(actionOk)
            }
            if let title = actionCancelTitle {
                let actionCancel: UIAlertAction = UIAlertAction(title: title, style: .default, handler: actionCancelHandler)
                alert.addAction(actionCancel)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
