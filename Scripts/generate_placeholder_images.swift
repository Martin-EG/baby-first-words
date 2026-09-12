#!/usr/bin/env swift
// Generates simple placeholder word-card images (colored background + large emoji)
// for every word in BabyFirstWords/Resources/lessons.json, and writes each one into
// an imageset folder in Assets.xcassets so Image(word_id) resolves in the app.
// Replace with real photos later by swapping the PNG inside each .imageset folder.

import AppKit
import Foundation

let emojiByWordID: [String: String] = [
    "mama": "🙋‍♀️", "papa": "🙋‍♂️", "baby": "👶", "hello": "👋", "bye": "👋",
    "dog": "🐶", "cat": "🐱", "bird": "🐦", "fish": "🐟", "cow": "🐮",
    "water": "💧", "milk": "🥛", "ball": "⚽️", "book": "📖", "more": "➕",
    "red": "❤️", "blue": "💙", "yellow": "💛", "green": "💚", "purple": "💜",
    "one": "1️⃣", "two": "2️⃣", "three": "3️⃣", "four": "4️⃣", "five": "5️⃣",
    "head": "😀", "hand": "✋", "foot": "🦶", "eye": "👁️", "nose": "👃",
    "shoe": "👟", "shirt": "👕", "hat": "🧢", "sock": "🧦", "pants": "👖",
    "eat": "🍽️", "sleep": "😴", "play": "🧸", "jump": "🤸", "hug": "🤗"
]

let colorByWordID: [String: NSColor] = [
    "mama": NSColor.systemPink, "papa": NSColor.systemBlue, "baby": NSColor.systemYellow,
    "hello": NSColor.systemOrange, "bye": NSColor.systemPurple,
    "dog": NSColor.systemBrown, "cat": NSColor.systemGray, "bird": NSColor.systemTeal,
    "fish": NSColor.systemCyan, "cow": NSColor.systemIndigo,
    "water": NSColor.systemBlue, "milk": NSColor.white, "ball": NSColor.systemGreen,
    "book": NSColor.systemRed, "more": NSColor.systemMint,
    "red": NSColor.systemRed, "blue": NSColor.systemBlue, "yellow": NSColor.systemYellow,
    "green": NSColor.systemGreen, "purple": NSColor.systemPurple,
    "one": NSColor.systemOrange, "two": NSColor.systemOrange, "three": NSColor.systemOrange,
    "four": NSColor.systemOrange, "five": NSColor.systemOrange,
    "head": NSColor.systemTeal, "hand": NSColor.systemTeal, "foot": NSColor.systemTeal,
    "eye": NSColor.systemTeal, "nose": NSColor.systemTeal,
    "shoe": NSColor.systemBlue, "shirt": NSColor.systemBlue, "hat": NSColor.systemBlue,
    "sock": NSColor.systemBlue, "pants": NSColor.systemBlue,
    "eat": NSColor.systemYellow, "sleep": NSColor.systemYellow, "play": NSColor.systemYellow,
    "jump": NSColor.systemYellow, "hug": NSColor.systemYellow
]

let projectRoot = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ".")
let assetsRoot = projectRoot.appendingPathComponent("BabyFirstWords/Assets.xcassets")
let size = 1024

func makeImage(wordID: String, emoji: String, background: NSColor) -> Data {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    background.setFill()
    NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 640),
        .paragraphStyle: paragraph
    ]
    let string = NSAttributedString(string: emoji, attributes: attrs)
    let stringSize = string.size()
    let rect = NSRect(
        x: (CGFloat(size) - stringSize.width) / 2,
        y: (CGFloat(size) - stringSize.height) / 2,
        width: stringSize.width,
        height: stringSize.height
    )
    string.draw(in: rect)
    image.unlockFocus()

    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        fatalError("Failed to render \(wordID)")
    }
    return png
}

for (wordID, emoji) in emojiByWordID {
    let color = colorByWordID[wordID] ?? .systemGray
    let imagesetDir = assetsRoot.appendingPathComponent("\(wordID).imageset")
    try? FileManager.default.createDirectory(at: imagesetDir, withIntermediateDirectories: true)

    let pngData = makeImage(wordID: wordID, emoji: emoji, background: color)
    let pngURL = imagesetDir.appendingPathComponent("\(wordID).png")
    try? pngData.write(to: pngURL)

    let contents = """
    {
      "images" : [
        {
          "filename" : "\(wordID).png",
          "idiom" : "universal",
          "scale" : "1x"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
    try? contents.write(to: imagesetDir.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
    print("Generated \(wordID).imageset")
}
