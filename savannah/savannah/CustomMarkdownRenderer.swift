//
//  CustomMarkdownRenderer.swift
//  savannah
//
//  Created by Kemal Erol on 13/09/2024.
//

import SwiftUI

struct CustomMarkdownRenderer: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(parseMarkdown(), id: \.self) { element in
                switch element {
                case .text(let text):
                    Text(text)
                        .font(.system(size: 14))
                        .foregroundColor(.customDark)
                case .header(let text, let level):
                    Text(text)
                        .font(.system(size: headerFontSize(for: level), weight: headerWeight(for: level)))
                        .foregroundColor(.customDark)
                        .padding(.top, headerTopPadding(for: level))
                case .link(let text, let url):
                    Link(text, destination: URL(string: url) ?? URL(string: "https://example.com")!)
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                case .image(let altText, let url):
                    AsyncImage(url: URL(string: url)) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .cornerRadius(8)
                    .padding(.vertical, 8)
                    .accessibilityLabel(altText)
                case .codeBlock(let code, _):
                    Text(code)
                        .font(.system(size: 14, design: .monospaced))
                        .padding(8)
                        .background(Color.customNavy.opacity(0.05))
                        .cornerRadius(8)
                case .listItem(let text):
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.customDark)
                            .frame(width: 4, height: 4)
                            .offset(y: 8)
                        Text(text)
                            .font(.system(size: 14))
                            .foregroundColor(.customDark)
                    }
                    .padding(.leading, 4)
                case .blockquote(let text):
                    Text(text)
                        .font(.system(size: 14, design: .serif))
                        .italic()
                        .padding(.leading, 8)
                        .overlay(
                            Rectangle()
                                .fill(Color.customTeal)
                                .frame(width: 2)
                                .padding(.leading, 4),
                            alignment: .leading
                        )
                }
            }
        }
    }
    
    private func parseMarkdown() -> [MarkdownElement] {
        let lines = content.components(separatedBy: .newlines)
        var elements: [MarkdownElement] = []
        var inCodeBlock = false
        var codeBlockContent = ""
        
        for line in lines {
            if line.hasPrefix("```") {
                if inCodeBlock {
                    elements.append(.codeBlock(code: codeBlockContent, language: nil))
                    codeBlockContent = ""
                }
                inCodeBlock.toggle()
            } else if inCodeBlock {
                codeBlockContent += line + "\n"
            } else if line.hasPrefix("#") {
                let level = line.prefix(while: { $0 == "#" }).count
                let text = line.dropFirst(level + 1)
                elements.append(.header(text: String(text), level: level))
            } else if line.hasPrefix("- ") {
                elements.append(.listItem(String(line.dropFirst(2))))
            } else if line.hasPrefix(">") {
                elements.append(.blockquote(String(line.dropFirst(2))))
            } else if line.contains("](") {
                // Simple link parsing
                let parts = line.components(separatedBy: "](")
                if parts.count == 2 {
                    let text = parts[0].dropFirst()
                    let url = parts[1].dropLast()
                    elements.append(.link(text: String(text), url: String(url)))
                } else {
                    elements.append(.text(line))
                }
            } else if line.hasPrefix("![") {
                // Simple image parsing
                let parts = line.components(separatedBy: "](")
                if parts.count == 2 {
                    let altText = parts[0].dropFirst(2)
                    let url = parts[1].dropLast()
                    elements.append(.image(altText: String(altText), url: String(url)))
                } else {
                    elements.append(.text(line))
                }
            } else {
                elements.append(.text(line))
            }
        }
        
        return elements
    }
    
    private func headerFontSize(for level: Int) -> CGFloat {
        switch level {
        case 1: return 20
        case 2: return 18
        case 3: return 16
        default: return 14
        }
    }
    
    private func headerWeight(for level: Int) -> Font.Weight {
        switch level {
        case 1: return .bold
        case 2: return .semibold
        default: return .medium
        }
    }
    
    private func headerTopPadding(for level: Int) -> CGFloat {
        switch level {
        case 1: return 16
        case 2: return 12
        case 3: return 8
        default: return 4
        }
    }
}

enum MarkdownElement: Hashable {
    case text(String)
    case header(text: String, level: Int)
    case link(text: String, url: String)
    case image(altText: String, url: String)
    case codeBlock(code: String, language: String?)
    case listItem(String)
    case blockquote(String)
}
