//
//  ChatViewController.swift
//  UChat
//
//  Created by Yuri Koshkin on 27/04/2025.
//


import UIKit

final class ChatViewController: UIViewController {

    private let tableView = UITableView()
    private let inputContainerView = UIView()
    private let textView = UITextView()

    private var inputBottomConstraint: NSLayoutConstraint?

    private var keyboardNotificationObserver: NSObjectProtocol?

    private var messages: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupTableView()
        setupInputBar()
        setupKeyboardObservers()
        setupTapToDismissKeyboard()
    }

    deinit {
        if let observer = keyboardNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupInputBar() {
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.backgroundColor = .secondarySystemBackground
        view.addSubview(inputContainerView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        inputContainerView.addSubview(textView)

        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.addSubview(sendButton)

        inputBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            inputContainerView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBottomConstraint!,

            textView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -8),

            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -8),
            sendButton.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 8),
            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupKeyboardObservers() {
        keyboardNotificationObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.handleKeyboardNotification(notification: notification)
        }
    }

    private func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tapGesture)
    }

    private func handleKeyboardNotification(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let curve = UIView.AnimationCurve(rawValue: Int(curveRaw)) ?? .easeInOut
        let keyboardVisibleHeight = view.frame.height - keyboardFrame.origin.y

        inputBottomConstraint?.constant = -keyboardVisibleHeight

        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func sendTapped() {
        guard !textView.text.isEmpty else { return }

        messages.append(textView.text)
        textView.text = ""
        tableView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let lastRow = self.messages.count - 1
            if lastRow >= 0 {
                let indexPath = IndexPath(row: lastRow, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = messages[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
