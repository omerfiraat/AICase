import UIKit
import SnapKit

class ChatViewController: UIViewController {
    private let tableView = UITableView()
    private let inputTextField = UITextField()
    private let chatService = ChatService()
    private let typingIndicatorLabel = UILabel()
    private var typingAnimationTimer: Timer?
    
    private var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardOnTap()
        setupUI()
        addInitialMessage()
        scrollToBottom()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        setupTableView()
        setupInputTextField()
        setupTypingIndicatorLabel()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatCell")
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupInputTextField() {
        inputTextField.delegate = self
        inputTextField.backgroundColor = .clear
        inputTextField.layer.cornerRadius = 16
        inputTextField.layer.borderColor = UIColor.lightGray.cgColor
        inputTextField.layer.borderWidth = 1
        inputTextField.textColor = .lightGray
        inputTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        inputTextField.leftViewMode = .always
        
        let placeholderText = "Type a message..."
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray
        ]
        inputTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        
        view.addSubview(inputTextField)
        inputTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-48)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.equalTo(50)
        }
        
        let sendButton = UIButton()
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.lightGray, for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.isUserInteractionEnabled = true
        
        inputTextField.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.width.equalTo(80)
            make.height.equalTo(50)
        }
    }
    
    private func setupTypingIndicatorLabel() {
        typingIndicatorLabel.font = UIFont.boldSystemFont(ofSize: 32)
        typingIndicatorLabel.textAlignment = .center
        typingIndicatorLabel.textColor = .white
        
        view.addSubview(typingIndicatorLabel)
        typingIndicatorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalTo(inputTextField.snp.top).offset(-8)
            make.width.equalTo(60)
        }
    }
    
    private func addInitialMessage() {
        let initialMessage = Message(text: "Merhabalar, bugün sizlere nasıl yardımcı olabilirim?", isSentByUser: false)
        messages.append(initialMessage)
    }
    
    @objc private func sendButtonTapped() {
        if let text = inputTextField.text, !text.isEmpty {
            sendMessage(text)
            inputTextField.text = nil
        }
    }
    
    private func startTypingAnimation() {
        typingIndicatorLabel.text = "..."
        typingIndicatorLabel.textColor = .white
        
        typingAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            UIView.transition(with: self.typingIndicatorLabel, duration: 0.5, options: .transitionCrossDissolve) {
                if self.typingIndicatorLabel.text == "..." {
                    self.typingIndicatorLabel.text = ".."
                } else if self.typingIndicatorLabel.text == ".." {
                    self.typingIndicatorLabel.text = "."
                } else {
                    self.typingIndicatorLabel.text = "..."
                }
            }
        }
        
        typingAnimationTimer?.fire()
    }
    
    private func stopTypingAnimation() {
        typingAnimationTimer?.invalidate()
        typingAnimationTimer = nil
        typingIndicatorLabel.text = ""
    }
    
    private func sendMessage(_ text: String) {
        startTypingAnimation()
        
        let message = Message(text: text, isSentByUser: true)
        messages.append(message)
        tableView.reloadData()
        
        chatService.getCompletion(prompt: text) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                let truncatedResponse = response.truncateAfterSecondSentence()
                let responseMessage = Message(text: truncatedResponse, isSentByUser: false)
                self.messages.append(responseMessage)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToBottom()
                    self.stopTypingAnimation()
                }
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func scrollToBottom() {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatTableViewCell
        let isLastBotMessage = indexPath.row == (messages.count - 1) && !message.isSentByUser
        cell.configure(with: message, isLastBotMessage: isLastBotMessage)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        let width = tableView.bounds.width
        return ChatTableViewCell.heightForMessage(message, width: width)
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            sendMessage(text)
            textField.text = nil
        }
        return true
    }
}

struct Message {
    var text: String
    var isSentByUser: Bool
    
    init(text: String, isSentByUser: Bool) {
        self.text = text
        self.isSentByUser = isSentByUser
    }
}
