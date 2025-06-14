import UIKit

class VocabularyTableViewCell: UITableViewCell {
    static let identifier = "VocabularyTableViewCell"
    
    private lazy var wordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var partOfSpeechLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.backgroundColor = .systemGray
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var definitionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var studyCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var partOfSpeechWidthConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(wordLabel)
        contentView.addSubview(partOfSpeechLabel)
        contentView.addSubview(definitionLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(studyCountLabel)
        
        partOfSpeechWidthConstraint = partOfSpeechLabel.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            partOfSpeechLabel.centerYAnchor.constraint(equalTo: wordLabel.centerYAnchor),
            partOfSpeechLabel.leadingAnchor.constraint(equalTo: wordLabel.trailingAnchor, constant: 8),
            partOfSpeechLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            partOfSpeechLabel.heightAnchor.constraint(equalToConstant: 20),
            partOfSpeechWidthConstraint!,
            
            definitionLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 4),
            definitionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            definitionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: definitionLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            studyCountLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            studyCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            studyCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: dateLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(with word: VocabularyWord) {
        wordLabel.text = word.word
        definitionLabel.text = word.definition
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = "Added \(dateFormatter.string(from: word.dateAdded))"
        
        if word.studyCount > 0 {
            studyCountLabel.text = "Studied \(word.studyCount) times"
            studyCountLabel.isHidden = false
        } else {
            studyCountLabel.isHidden = true
        }
        
        if let partOfSpeech = word.partOfSpeech {
            partOfSpeechLabel.text = " \(partOfSpeech.uppercased()) "
            partOfSpeechLabel.isHidden = false
            partOfSpeechWidthConstraint?.isActive = false
        } else {
            partOfSpeechLabel.isHidden = true
            partOfSpeechWidthConstraint?.isActive = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        partOfSpeechLabel.isHidden = false
        studyCountLabel.isHidden = false
        partOfSpeechWidthConstraint?.isActive = false
    }
}