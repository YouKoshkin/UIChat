//
//  ChatViewController.swift
//  UChat
//
//  Created by Yuri Koshkin on 27/04/2025.
//


import UIKit

final class ChatViewController: UIViewController {

    private var messages: [String] = []
    private var mockData: [String] = [
        "Hey! What's up?",
        "Just got back from the gym.",
        "Oh nice! How was it?",
        "Pretty good, feeling energized.",
        "Cool! What are you working on?",
        "Just browsing some articles online.",
        "Anything interesting?",
        "Yeah, a few things about AI.",
        "That's fascinating!",
        "Tell me about it later?",
        "Sure thing! What about you?",
        "Just finished making dinner.",
        "Ooh, what did you have?",
        "Pasta with pesto and chicken.",
        "Sounds delicious!",
        "It was pretty good, thanks!",
        "So, what are your plans for tonight?",
        "Not sure yet, maybe watch a movie.",
        "That sounds relaxing.",
        "Yeah, definitely need to unwind."
    ]
    private let tableView = UITableView()
    private let inputContainerView = UIView()
    private let textView = UITextView()
    
    private var keyboardNotificationObserver: NSObjectProtocol?
    private var inputBottomConstraint: NSLayoutConstraint?
    private var keyboardHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground

        setupTableView()
        setupInputBar()
        setupKeyboardObservers()
        setupTapToDismissKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if messages.isEmpty {
            textView.becomeFirstResponder()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if tableView.contentSize.height > tableView.bounds.height {
            tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0),
                                  at: .bottom,
                                  animated: false)
        }
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
        tableView.showsVerticalScrollIndicator = false
        tableView.scrollsToTop = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func setupInputBar() {
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.backgroundColor = .secondarySystemBackground
        view.addSubview(inputContainerView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        textView.autocorrectionType = .no
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
            textView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 32),
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

    // MARK: - on Keyboard appear/disappear
    private func handleKeyboardNotification(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        keyboardHeight = view.frame.height - keyboardFrame.origin.y
        inputBottomConstraint?.constant = keyboardHeight > 0 ? -keyboardHeight + view.safeAreaInsets.bottom : 0

        let curve = UIView.AnimationCurve(rawValue: Int(curveRaw)) ?? .easeInOut
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            self.tableView.verticalScrollIndicatorInsets.top = self.tableTopInset
            self.tableView.contentInset = UIEdgeInsets(top: self.tableTopInset, left: 0, bottom: 0, right: 0)
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()

        /// laggy animation
        if tableView.contentSize.height > tableView.bounds.height {
            self.scrollToBootom()
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func sendTapped() {
        let message = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        textView.text = ""

        guard !message.isEmpty else { return }

        messages.append(message)
        tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .bottom)

        self.animateContentInsets()
        self.scrollToBootom()
    }

    private func scrollToBootom() {
        let lastRow = messages.count - 1
        if lastRow > 0 {
            let indexPath = IndexPath(row: lastRow, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    // MARK: - Stick to Bottom
    /// moves messages down to TextEditor,
    /// only for content is smaller than screen, otherwise = 0
    private var tableTopInset: CGFloat {
        guard tableView.contentSize.height > 0 else {
            return tableView.frame.height - keyboardHeight + view.safeAreaInsets.bottom
        }
        var inset: CGFloat = 0
        let safeAreHeight: CGFloat = view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        let availableHeightForTableView = safeAreHeight - keyboardHeight - inputContainerView.frame.height

        /// only for content is smaller than screen
        if availableHeightForTableView > tableView.contentSize.height {
            inset = availableHeightForTableView - tableView.contentSize.height
            /// removes gap when keyboard is open
            if keyboardHeight > 0 {
                inset = inset + view.safeAreaInsets.bottom
            }
        }
        return inset
    }

    private func animateContentInsets() {
        UIView.animate(withDuration: 0.3) {
            self.tableView.contentInset = UIEdgeInsets(top: self.tableTopInset, left: 0, bottom: 0, right: 0)
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = messages[indexPath.row]
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
