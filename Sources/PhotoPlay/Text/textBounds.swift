#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit

func textBounds(_ attributedText: NSAttributedString) -> CGRect {
    attributedText.boundingRect(
        with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        context: nil
    )
}
#elseif os(macOS)
import AppKit

func textBounds(_ attributedText: NSAttributedString) -> CGRect {
    attributedText.boundingRect(
        with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        context: nil
    )
}
#else
import Foundation

func textBounds(_ attributedText: NSAttributedString) -> CGRect {
    CGRect.zero
}
#endif
