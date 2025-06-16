import UIKit
import Observation

class SettingsViewController: UIViewController {
    private let ocrServiceManager: OCRServiceManager
    
    init(ocrServiceManager: OCRServiceManager) {
        self.ocrServiceManager = ocrServiceManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ocrSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "OCR Provider"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ocrDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose how to extract text from book page images"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var visionProviderView: UIView = {
        let view = createProviderSelectionView(
            title: "iOS Vision",
            description: "Apple's built-in text recognition",
            providerType: .vision
        )
        return view
    }()
    
    private lazy var openAIProviderView: UIView = {
        let view = createProviderSelectionView(
            title: "OpenAI API",
            description: "AI-powered text extraction via OpenAI",
            providerType: .openAI
        )
        return view
    }()
    
    private lazy var openAISectionLabel: UILabel = {
        let label = UILabel()
        label.text = "OpenAI Configuration"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var apiKeyLabel: UILabel = {
        let label = UILabel()
        label.text = "API Key"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var apiKeyTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "sk-..."
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textField.addTarget(self, action: #selector(apiKeyChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var apiKeyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Your OpenAI API key is required to use OpenAI OCR. Get one at platform.openai.com"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemGray2
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Done"
        config.cornerStyle = .medium
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        button.configuration = config
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadCurrentSettings()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, ocrSectionLabel, ocrDescriptionLabel, visionProviderView, openAIProviderView, 
         openAISectionLabel, apiKeyLabel, apiKeyTextField, apiKeyDescriptionLabel, doneButton].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // OCR Section
            ocrSectionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            ocrSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ocrSectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            ocrDescriptionLabel.topAnchor.constraint(equalTo: ocrSectionLabel.bottomAnchor, constant: 8),
            ocrDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ocrDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            visionProviderView.topAnchor.constraint(equalTo: ocrDescriptionLabel.bottomAnchor, constant: 20),
            visionProviderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            visionProviderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            openAIProviderView.topAnchor.constraint(equalTo: visionProviderView.bottomAnchor, constant: 12),
            openAIProviderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            openAIProviderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // OpenAI Section
            openAISectionLabel.topAnchor.constraint(equalTo: openAIProviderView.bottomAnchor, constant: 40),
            openAISectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            openAISectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            apiKeyLabel.topAnchor.constraint(equalTo: openAISectionLabel.bottomAnchor, constant: 20),
            apiKeyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            apiKeyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            apiKeyTextField.topAnchor.constraint(equalTo: apiKeyLabel.bottomAnchor, constant: 8),
            apiKeyTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            apiKeyTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            apiKeyTextField.heightAnchor.constraint(equalToConstant: 44),
            
            apiKeyDescriptionLabel.topAnchor.constraint(equalTo: apiKeyTextField.bottomAnchor, constant: 8),
            apiKeyDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            apiKeyDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Done Button
            doneButton.topAnchor.constraint(equalTo: apiKeyDescriptionLabel.bottomAnchor, constant: 40),
            doneButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func createProviderSelectionView(title: String, description: String, providerType: OCRProviderType) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let radioButton = UIButton(type: .system)
        radioButton.setImage(UIImage(systemName: "circle"), for: .normal)
        radioButton.setImage(UIImage(systemName: "circle.fill"), for: .selected)
        radioButton.tintColor = .systemBlue
        radioButton.tag = providerType.rawValue.hashValue
        radioButton.addTarget(self, action: #selector(providerSelectionChanged(_:)), for: .touchUpInside)
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .systemGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(radioButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            radioButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            radioButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            radioButton.widthAnchor.constraint(equalToConstant: 24),
            radioButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        // Add tap gesture to the entire container
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(providerContainerTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
        containerView.tag = providerType.rawValue.hashValue
        
        return containerView
    }
    
    private func setupBindings() {
        startObservingOCRService()
    }
    
    private func startObservingOCRService() {
        withObservationTracking {
            // Access the property we want to observe
            _ = ocrServiceManager.selectedProviderType
        } onChange: {
            Task { @MainActor in
                self.updateProviderSelection()
                self.startObservingOCRService() // Re-establish tracking
            }
        }
    }
    
    private func loadCurrentSettings() {
        // Load API key
        apiKeyTextField.text = UserDefaults.standard.string(forKey: "openai_api_key")
        
        // Update provider selection
        updateProviderSelection()
    }
    
    private func updateProviderSelection() {
        // Update radio buttons
        updateRadioButton(in: visionProviderView, selected: ocrServiceManager.selectedProviderType == .vision)
        updateRadioButton(in: openAIProviderView, selected: ocrServiceManager.selectedProviderType == .openAI)
    }
    
    private func updateRadioButton(in containerView: UIView, selected: Bool) {
        for subview in containerView.subviews {
            if let button = subview as? UIButton {
                button.isSelected = selected
                break
            }
        }
    }
    
    @objc private func providerSelectionChanged(_ sender: UIButton) {
        let providerType: OCRProviderType = sender.tag == OCRProviderType.vision.rawValue.hashValue ? .vision : .openAI
        ocrServiceManager.selectedProviderType = providerType
    }
    
    @objc private func providerContainerTapped(_ gesture: UITapGestureRecognizer) {
        guard let containerView = gesture.view else { return }
        let providerType: OCRProviderType = containerView.tag == OCRProviderType.vision.rawValue.hashValue ? .vision : .openAI
        ocrServiceManager.selectedProviderType = providerType
    }
    
    @objc private func apiKeyChanged() {
        guard let apiKey = apiKeyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if apiKey.isEmpty {
            UserDefaults.standard.removeObject(forKey: "openai_api_key")
        } else {
            UserDefaults.standard.set(apiKey, forKey: "openai_api_key")
        }
    }
    
    @objc private func doneButtonTapped() {
        dismiss(animated: true)
    }
}