import UIKit
import SnapKit

class ChatTableViewCell: UITableViewCell {
    private let messageLabel = UILabel()
    private let messageBackgroundView = UIView()
    private let profileImageView = UIImageView()
    private var typingTimer: Timer?
    private var currentText = ""
    private var currentIndex = 0
    private let maxMessageWidthRatio: CGFloat = 0.7
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .black
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 16
        
        messageBackgroundView.layer.cornerRadius = 16
        messageBackgroundView.clipsToBounds = true
        
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        
        addSubview(profileImageView)
        addSubview(messageBackgroundView)
        messageBackgroundView.addSubview(messageLabel)
        
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(32)
        }
        
        messageBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            make.width.lessThanOrEqualToSuperview().multipliedBy(maxMessageWidthRatio)
        }
    }
    
    func configure(with message: Message, isLastBotMessage: Bool) {
        messageLabel.text = message.text
        
        if message.isSentByUser {
            messageBackgroundView.backgroundColor = .clear
            messageBackgroundView.layer.borderWidth = 1
            messageBackgroundView.layer.borderColor = UIColor.systemBlue.cgColor
            messageLabel.textColor = .systemBlue
            messageLabel.textAlignment = .right
            profileImageView.isHidden = true
        } else {
            messageBackgroundView.backgroundColor = .clear
            messageBackgroundView.layer.borderWidth = 1
            messageBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
            messageLabel.textColor = .lightGray
            messageLabel.textAlignment = .left
            profileImageView.isHidden = false
            profileImageView.image = UIImage(named: "vinylBot")
            
            if isLastBotMessage {
                startTypewriterAnimation(with: message.text)
            } else {
                messageLabel.text = message.text
            }
        }
        
        let labelWidth = UIScreen.main.bounds.width * maxMessageWidthRatio - 8 - 16
        let labelHeight = message.text.height(withConstrainedWidth: labelWidth, font: UIFont.systemFont(ofSize: 16))
        let cellHeight = labelHeight + 16
        
        messageBackgroundView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            if message.isSentByUser {
                make.trailing.equalToSuperview().offset(-16)
            } else {
                make.leading.equalTo(profileImageView.snp.trailing).offset(8)
                make.trailing.equalToSuperview().offset(-16)
            }
        }
        
        messageLabel.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            make.width.lessThanOrEqualTo(labelWidth)
            make.height.equalTo(labelHeight)
        }
        
        layoutIfNeeded()
    }
    
    static func heightForMessage(_ message: Message, width: CGFloat) -> CGFloat {
        let labelWidth = width - 8 - 32 - 8 - 16
        let labelHeight = message.text.height(withConstrainedWidth: labelWidth, font: UIFont.systemFont(ofSize: 16))
        let cellHeight = labelHeight + 16
        return cellHeight
    }
    
    private func startTypewriterAnimation(with text: String) {
        typingTimer?.invalidate()
        
        currentText = ""
        currentIndex = 0
        
        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: self.currentIndex)
                self.currentText += String(text[index])
                self.messageLabel.text = self.currentText
                
                self.currentIndex += 1
            } else {
                self.typingTimer?.invalidate()
                self.typingTimer = nil
            }
        }
    }
}
