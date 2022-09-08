# JapaneseAttributesKit

AttributedString extensions for vertical text styling.

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/swiftty/JapaneseAttributesKit", from: "0.0.1")
]
```

## Usage

by code.

```swift
import Foundation
import JapaneseAttributesKit

var string = AttributedString("あのイーハトーヴォのすきとおった")
string += {
    var string = AttributedString("風")
    string.ruby = .init(text: "かぜ")
    return string
}()
string.verticalGlyph = true
```

by markdown.

```swift
import Foundation
import JapaneseAttributesKit

var string = try AttributedString(markdown: "あのイーハトーヴォのすきとおった^[風](ruby: 'かぜ')", including: \.japanese)
string.verticalGlyph = true
```

## License

    JapaneseAttributesKit is available under the MIT license, and uses source code from open source projects. See the [LICENSE](https://github.com/swiftty/JapaneseAttributesKit/blob/main/LICENSE) file for more info.
