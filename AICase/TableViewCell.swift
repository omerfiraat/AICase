import UIKit
import SnapKit

class ChatTableViewCell: UITableViewCell {
    let messageLabel = UILabel()
    let messageBackgroundView = UIView()
    let profileImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        self.backgroundColor = .black

        // ProfileImageView settings
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true

        // MessageBackgroundView settings
        messageBackgroundView.layer.cornerRadius = 16
        messageBackgroundView.clipsToBounds = true

        // MessageLabel settings
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 16)

        // Adding subviews to the cell
        addSubview(profileImageView)
        addSubview(messageBackgroundView)
        messageBackgroundView.addSubview(messageLabel)

        // ProfileImageView layout constraints
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(32)
        }

        // MessageBackgroundView layout constraints
        messageBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
        }

        // MessageLabel layout constraints
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }
    }

    func configure(with message: Message) {
        messageLabel.text = message.text

        if message.isSentByUser {
            messageBackgroundView.backgroundColor = UIColor.systemBlue
            messageLabel.textColor = UIColor.white
            messageLabel.textAlignment = .right
            profileImageView.isHidden = true
        } else {
            messageBackgroundView.backgroundColor = UIColor.lightGray
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = .left
            profileImageView.isHidden = false
            profileImageView.image = UIImage(named: "vinylBot") // Replace with your image name
        }

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
    }

    static func heightForMessage(_ message: Message) -> CGFloat {
        let labelWidth = UIScreen.main.bounds.width - 8 - 32 - 8 - 16 // Total width minus profile image and padding
        let labelHeight = message.text.height(withConstrainedWidth: labelWidth, font: UIFont.systemFont(ofSize: 16))
        let cellHeight = labelHeight + 16 // Padding top and bottom
        return cellHeight
    }
}



