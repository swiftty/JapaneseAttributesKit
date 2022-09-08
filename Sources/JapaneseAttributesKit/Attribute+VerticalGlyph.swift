import Foundation

public enum VerticalGlyphFormAttribute: CodableAttributedStringKey {
    public static var name: String { NSAttributedString.Key.verticalGlyphForm.rawValue }
    public typealias Value = Bool
}
