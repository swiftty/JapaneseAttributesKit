import Foundation
#if canImport(UIKit)
import UIKit
#endif

extension AttributeScopes {
    public struct JapaneseAttributes: AttributeScope {
        public let ruby: RubyAttribute
        public let verticalGlyph: VerticalGlyphFormAttribute

        public let foundation: FoundationAttributes
        #if canImport(UIKit)
        public let uiKit: UIKitAttributes
        #endif
    }

    public var japanese: JapaneseAttributes.Type { JapaneseAttributes.self }
}

extension AttributeDynamicLookup {
    public subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.JapaneseAttributes, T>) -> T {
        return self[T.self]
    }
}
