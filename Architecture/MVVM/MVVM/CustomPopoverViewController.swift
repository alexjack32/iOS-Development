import UIKit

class CustomActionSheetViewController: UIViewController {
    // Container view for the custom action sheet content
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "More"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let captionsSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let captionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Captions – English (Automated)"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let swipingSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let swipingLabel: UILabel = {
        let label = UILabel()
        label.text = "Swiping controls"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(dismissActionSheet), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        view.addSubview(containerView)
    }
    
    private func setupLayout() {
        containerView.addSubview(titleLabel)
        containerView.addSubview(captionsSwitch)
        containerView.addSubview(captionsLabel)
        containerView.addSubview(swipingSwitch)
        containerView.addSubview(swipingLabel)
        containerView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 250), // Adjust height as needed
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            captionsSwitch.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            captionsSwitch.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            captionsLabel.centerYAnchor.constraint(equalTo: captionsSwitch.centerYAnchor),
            captionsLabel.leadingAnchor.constraint(equalTo: captionsSwitch.trailingAnchor, constant: 16),
            
            swipingSwitch.topAnchor.constraint(equalTo: captionsSwitch.bottomAnchor, constant: 24),
            swipingSwitch.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            swipingLabel.centerYAnchor.constraint(equalTo: swipingSwitch.centerYAnchor),
            swipingLabel.leadingAnchor.constraint(equalTo: swipingSwitch.trailingAnchor, constant: 16),
            
            cancelButton.topAnchor.constraint(equalTo: swipingSwitch.bottomAnchor, constant: 32),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func dismissActionSheet() {
        dismiss(animated: true, completion: nil)
    }
}
