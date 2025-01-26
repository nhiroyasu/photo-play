import CoreGraphics

enum Theme: Int {
    case selectionBorder = 0x195fff
    case croppingGuideBorder = 0x121212

    var cgColor: CGColor {
        CGColor(
            red: CGFloat((self.rawValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((self.rawValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(self.rawValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
