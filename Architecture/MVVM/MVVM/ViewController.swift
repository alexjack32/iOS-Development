import UIKit

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        let showActionSheetButton = UIButton(type: .system)
        showActionSheetButton.setTitle("Show Custom Action Sheet", for: .normal)
        showActionSheetButton.translatesAutoresizingMaskIntoConstraints = false
        showActionSheetButton.addTarget(self, action: #selector(showCustomActionSheet), for: .touchUpInside)
        
        view.addSubview(showActionSheetButton)
        NSLayoutConstraint.activate([
            showActionSheetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showActionSheetButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func showCustomActionSheet() {
        let customActionSheetVC = CustomActionSheetViewController()
        customActionSheetVC.modalPresentationStyle = .custom
        customActionSheetVC.transitioningDelegate = self
        present(customActionSheetVC, animated: true, completion: nil)
    }

    // MARK: - UIViewControllerTransitioningDelegate

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
