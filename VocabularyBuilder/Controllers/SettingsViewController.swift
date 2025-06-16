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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadCurrentSettings()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        self.title = "Settings"

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [ocrSectionLabel, ocrDescriptionLabel, visionProviderView, openAIProviderView].forEach {
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

            // OCR Section
            ocrSectionLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
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
            openAIProviderView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func createProviderSelectionView(title: String, description: String, providerType: OCRProviderType) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let radioButton = UIButton(type: .system)
        radioButton.setImage(UIImage(systemName: "circle"), for: .normal)
//        radioButton.setImage(UIImage(systemName: "circle.fill"), for: .selected)
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
    
    @objc private func doneButtonTapped() {
        dismiss(animated: true)
    }
}
