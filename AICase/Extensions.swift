//
//  Extensions.swift
//  AICase
//
//  Created by Ömer Firat on 21.05.2023.
//

import Foundation
import UIKit


extension String {
    func truncateAfterSecondSentence(trailing: String = "") -> String {
        var sentenceCount = 0
        var endIndex = self.startIndex
        
        // İkinci cümleye kadar olan end index'i bulma
        while let range = self[endIndex...].range(of: #"[.!?]"#, options: .regularExpression) {
            endIndex = range.upperBound
            sentenceCount += 1
            
            if sentenceCount >= 2 {
                break
            }
        }
        
        if sentenceCount >= 2 {
            return String(self[..<endIndex]) + trailing
        } else {
            return self
        }
    }
}

extension ChatTableViewCell {
    static func heightForMessage(_ message: Message, width: CGFloat) -> CGFloat {
        let messageLabelWidth = width * 0.7 - 24
        let font = UIFont.systemFont(ofSize: 16)
        let messageText = message.text
        let messageLabelHeight = messageText.height(withConstrainedWidth: messageLabelWidth, font: font)
        let cellHeight = messageLabelHeight + 16
        return cellHeight
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}

extension UIViewController {
    func hideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

