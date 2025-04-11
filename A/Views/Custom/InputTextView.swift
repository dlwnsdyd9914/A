//
//  InputTextView.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit
import SnapKit
import Then

final class InputTextView: UITextView, UITextViewDelegate {

    // MARK: - Subviews

    private let overlayView = UIView()

    let placeholderLabel = UILabel().then {
        $0.text = "What's happening?"
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .lightGray
    }


    // MARK: - Properties

    private let minHeight: CGFloat = 50
    private let maxHeight: CGFloat = 250
    private let maxCharacters: Int = 200


    var onHeightChange: (() -> Void)?

    weak var customTextViewDelegate: UITextViewDelegate?

    override var delegate: UITextViewDelegate? {
        didSet {
            customTextViewDelegate = delegate
        }
    }

    // MARK: - Init

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        super.delegate = self
        configureUI()
        setup()
        configureConstraints()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextInputChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    // MARK: - UI Setup

    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        font = .systemFont(ofSize: 16)
        textColor = .black
        isScrollEnabled = false

        textContainer.lineBreakMode = .byWordWrapping
        textContainer.widthTracksTextView = true
        textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 28, right: 4) // 아래 여백 확보
    }

    private func setup() {
        addSubview(overlayView)
        overlayView.addSubview(placeholderLabel)


        super.delegate = self
    }

    private func configureConstraints() {
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(4)
        }


    }

    // MARK: - Text Handling

    @objc private func handleTextInputChange() {
        placeholderLabel.isHidden = !self.text.isEmpty


        invalidateIntrinsicContentSize()
        superview?.layoutIfNeeded()
        onHeightChange?()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= maxCharacters
    }

    func textViewDidChange(_ textView: UITextView) {
        customTextViewDelegate?.textViewDidChange?(textView)
    }

    // MARK: - Height

    override var intrinsicContentSize: CGSize {
        let fittingSize = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        let contentHeight = sizeThatFits(fittingSize).height
        return CGSize(width: bounds.width, height: min(max(contentHeight, minHeight), maxHeight))
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
