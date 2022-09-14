import XCTest
import Foundation
import CoreText
@testable import JapaneseAttributesKit

final class JapaneseAttributesKitTests: XCTestCase {
    func test_applied_attributes() throws {
        var string = AttributedString("abcdefg")
        var hij = AttributedString("hij")
        hij.ruby = .init(text: "HIJ")
        string += hij
        string += "klmn"
        string.verticalGlyph = true

        XCTAssertEqual(String(string.characters), "abcdefghijklmn")
        XCTAssertEqual(string.runs.count, 3)
        for (index, run) in string.runs.enumerated() {
            let substring = string[run.range]
            XCTAssertEqual(substring.verticalGlyph, true)

            switch index {
            case 0, 2:
                XCTAssertEqual(String(substring.characters), index == 0 ? "abcdefg" : "klmn")
                XCTAssertNil(substring.ruby)

            case 1:
                XCTAssertEqual(String(substring.characters), "hij")
                XCTAssertEqual(substring.ruby?.text, .default("HIJ"))

            default:
                XCTFail()
            }
        }
    }

    func test_markdown() throws {
        let string = try AttributedString(markdown: "abcdefg^[hij](ruby: 'HIJ')klmn", including: \.japanese)

        XCTAssertEqual(String(string.characters), "abcdefghijklmn")
        XCTAssertEqual(string.runs.count, 3)
        for (index, run) in string.runs.enumerated() {
            let substring = string[run.range]

            switch index {
            case 0, 2:
                XCTAssertEqual(String(substring.characters), index == 0 ? "abcdefg" : "klmn")
                XCTAssertNil(substring.ruby)

            case 1:
                XCTAssertEqual(String(substring.characters), "hij")
                XCTAssertEqual(substring.ruby?.text, .default("HIJ"))

            default:
                XCTFail()
            }
        }
    }

    func test_nsattributedstring() throws {
        var string = try AttributedString(markdown: "abcdefg^[hij](ruby: 'HIJ')klmn", including: \.japanese)
        string.verticalGlyph = true

        let nsText = try NSAttributedString(string, including: \.japanese)
        XCTAssertEqual(nsText.string, "abcdefghijklmn")

        var expected = [
            (range: NSRange(location: 0, length: 7),
             keys: [NSAttributedString.Key.verticalGlyphForm.rawValue]),
            (range: NSRange(location: 7, length: 3),
             keys: [NSAttributedString.Key.verticalGlyphForm.rawValue, kCTRubyAnnotationAttributeName as String]),
            (range: NSRange(location: 10, length: 4),
             keys: [NSAttributedString.Key.verticalGlyphForm.rawValue])
        ]
        nsText.enumerateAttributes(in: NSRange(location: 0, length: nsText.string.utf16.count)) { attributes, range, _ in

            let e = expected[0]
            XCTAssertEqual(range, e.range)
            XCTAssertEqual(Set(e.keys).subtracting(attributes.keys.map(\.rawValue)), [])

            if e.keys.contains(kCTRubyAnnotationAttributeName as String) {
                guard let a = attributes[kCTRubyAnnotationAttributeName as NSAttributedString.Key],
                      let annotation = (a as? CTRubyAnnotation?) ?? nil else {
                    XCTFail("attributes must has CTRubyAnnotation")
                    return
                }
                XCTAssertEqual(CTRubyAnnotationGetTextForPosition(annotation, .before) as String?, "HIJ")
            }

            expected.remove(at: 0)
        }

        XCTAssertEqual(expected.count, 0)
    }

    func test_codable() throws {
        struct Container: Codable {
            var string: AttributedString

            init() throws {
                string = try AttributedString(markdown: "abcdefg^[hij](ruby: 'HIJ')klmn", including: \.japanese)
                string.verticalGlyph = true
            }

            enum CodingKeys: CodingKey {
                case string
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                string = try container.decode(AttributedString.self, forKey: .string, configuration: AttributeScopes.JapaneseAttributes.self)
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(string, forKey: .string, configuration: AttributeScopes.JapaneseAttributes.self)
            }
        }

        let container = try Container()
        let data = try JSONEncoder().encode(container)

        let decoded = try JSONDecoder().decode(Container.self, from: data)
        XCTAssertEqual(decoded.string.verticalGlyph, true)
        XCTAssertEqual(String(decoded.string.characters), "abcdefghijklmn")
        XCTAssertEqual(decoded.string.runs.count, 3)
        for (index, run) in decoded.string.runs.enumerated() {
            let substring = decoded.string[run.range]

            switch index {
            case 0, 2:
                XCTAssertEqual(String(substring.characters), index == 0 ? "abcdefg" : "klmn")
                XCTAssertNil(substring.ruby)

            case 1:
                XCTAssertEqual(String(substring.characters), "hij")
                XCTAssertEqual(substring.ruby?.text, .default("HIJ"))

            default:
                XCTFail()
            }
        }
    }
}
