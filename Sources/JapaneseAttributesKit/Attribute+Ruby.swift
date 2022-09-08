import Foundation
import CoreText

public enum RubyAttribute: CodableAttributedStringKey,
                           MarkdownDecodableAttributedStringKey,
                           ObjectiveCConvertibleAttributedStringKey {
    public static var name: String { kCTRubyAnnotationAttributeName as String }
    public static var markdownName: String { "ruby" }

    public struct Value: Hashable, Codable {
        public var text: Content
        public var sizeFactor: CGFloat?
        public var alignment: Alignment?
        public var overhang: Overhang?

        public init(
            text: Content,
            sizeFactor: CGFloat? = nil,
            alignment: Alignment? = nil,
            overhang: Overhang? = nil
        ) {
            self.text = text
            self.alignment = alignment
            self.overhang = overhang
        }

        public init(
            text: String,
            sizeFactor: CGFloat? = nil,
            alignment: Alignment? = nil,
            overhang: Overhang? = nil
        ) {
            self.text = .default(text)
            self.alignment = alignment
            self.overhang = overhang
        }

        public enum Content: Hashable, Codable, ExpressibleByStringLiteral {
            case `default`(String)
            case custom([Position: String])

            public init(stringLiteral value: String) {
                self = .default(value)
            }
        }
        public enum Alignment: UInt8, Hashable, Codable {
            case invalid = 255
            case auto = 0
            case start = 1
            case center = 2
            case end = 3
            case distributeLetter = 4
            case distributeSpace = 5
            case lineEdge = 6
        }
        public enum Overhang : UInt8, Hashable, Codable {
            case invalid = 255
            case auto = 0
            case start = 1
            case end = 2
            case none = 3
        }
        public enum Position : UInt8, Hashable, Codable {
            case before = 0
            case after = 1
            case interCharacter = 2
            case inline = 3
        }
    }

    public static func decodeMarkdown(from decoder: Decoder) throws -> Value {
        let text = try decoder.singleValueContainer().decode(String.self)
        return .init(text: text)
    }

    public static func objectiveCValue(for value: Value) throws -> NSObject {
        func index(of p: Value.Position) -> Int {
            Int(CTRubyPosition(p).rawValue)
        }

        var texts: [Unmanaged<CFString>?] = .init(repeating: nil, count: Int(CTRubyPosition.count.rawValue))
        defer { texts.forEach { $0?.release() } }

        switch value.text {
        case .default(let text):
            texts[index(of: .before)] = .passRetained(text as CFString)
        case .custom(let text):
            precondition(!text.isEmpty)
            for (position, text) in text {
                texts[index(of: position)] = .passRetained(text as CFString)
            }
        }

        let ruby = CTRubyAnnotationCreate(.init(value.alignment), .init(value.overhang), value.sizeFactor ?? 0.5, &texts)
        return ruby as AnyObject as! NSObject
    }

    public static func value(for object: NSObject) throws -> Value {
        let object = object as! CTRubyAnnotation

        var texts: [Value.Position: String] = [:]
        for p in [CTRubyPosition.before, .after, .interCharacter, .inline] {
            if let text = CTRubyAnnotationGetTextForPosition(object, p), let p = Value.Position(rawValue: p.rawValue) {
                texts[p] = text as String
            }
        }
        precondition(!texts.isEmpty)

        let sizeFactor = CTRubyAnnotationGetSizeFactor(object)
        let alignment = Value.Alignment(rawValue: CTRubyAnnotationGetAlignment(object).rawValue)
        let overhang = Value.Overhang(rawValue: CTRubyAnnotationGetOverhang(object).rawValue)
        return Value(
            text: .custom(texts),
            sizeFactor: sizeFactor,
            alignment: alignment,
            overhang: overhang
        )
    }
}


// MARK: - private
private extension CTRubyAlignment {
    init(_ val: RubyAttribute.Value.Alignment?) {
        self = val.map(\.rawValue).flatMap(CTRubyAlignment.init(rawValue:)) ?? .auto
    }
}

private extension CTRubyOverhang {
    init(_ val: RubyAttribute.Value.Overhang?) {
        self = val.map(\.rawValue).flatMap(CTRubyOverhang.init(rawValue:)) ?? .auto
    }
}

private extension CTRubyPosition {
    init(_ val: RubyAttribute.Value.Position?) {
        self = val.map(\.rawValue).flatMap(CTRubyPosition.init(rawValue:)) ?? .before
    }
}
