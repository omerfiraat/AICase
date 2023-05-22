import UIKit
import SnapKit

class ChatViewController: UIViewController {
    private let tableView = UITableView()
    private let inputTextField = UITextField()
    private let chatService = ChatService()

    private var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardOnTap()
        setupUI()
    }

    private func setupUI() {
        
        view.backgroundColor = .black
        // TableView settings
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black

        // TableView cell registration
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatCell")

        // TableView layout constraints
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // InputTextField settings
        inputTextField.delegate = self
        inputTextField.backgroundColor = .lightGray
        inputTextField.placeholder = "Type a message..."

        // InputTextField layout constraints
        view.addSubview(inputTextField)
        inputTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(50)
        }
    }

    private func sendMessage(_ text: String) {
        let message = Message(text: text, isSentByUser: true)
        messages.append(message)

        tableView.reloadData()

        chatService.getCompletion(prompt: text) { [weak self] result in
            switch result {
            case .success(let response):
                let truncatedResponse = response.truncateAfterSecondSentence()
                let responseMessage = Message(text: truncatedResponse, isSentByUser: false)
                self?.messages.append(responseMessage)

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.scrollToBottom()
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
        cell.configure(with: message)

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

