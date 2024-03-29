//
//  File.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023-10-20.
//

import SwiftUI

public struct DeepStyle {
    
    public enum Indentation {
        case horizontal
        case leading
        case depth
        case leadingDepth
        var isLeading: Bool {
            switch self {
            case .leading, .leadingDepth:
                true
            default:
                false
            }
        }
        var isDepth: Bool {
            switch self {
            case .depth, .leadingDepth:
                true
            default:
                false
            }
        }
    }

    public var rowHeight: CGFloat
    public var indentation: Indentation
    public var indentationPadding: CGFloat
    public var separatorHeight: CGFloat
    public var scrollTopEdgeInset: CGFloat
    public var scrollBottomEdgeInset: CGFloat
    public var listPadding: CGFloat
    public var listCornerRadius: CGFloat
    public var separatorColor: Color
    public var backgroundColor: Color
    
    public init(
        rowHeight: CGFloat = {
#if os(macOS)
            return 30
#else
            return 40
#endif
        }(),
        indentation: Indentation = .leading,
        indentationPadding: CGFloat = 16,
        separatorHeight: CGFloat = 3,
        scrollTopEdgeInset: CGFloat = 0.0,
        scrollBottomEdgeInset: CGFloat = 0.0,
        listPadding: CGFloat = 0.0,
        listCornerRadius: CGFloat = 0.0,
        separatorColor: Color = .accentColor,
        backgroundColor: Color = .clear
    ) {
        self.rowHeight = rowHeight
        self.indentation = indentation
        self.indentationPadding = indentationPadding
        self.separatorHeight = separatorHeight
        self.scrollTopEdgeInset = scrollTopEdgeInset
        self.scrollBottomEdgeInset = scrollBottomEdgeInset
        self.listPadding = listPadding
        self.listCornerRadius = listCornerRadius
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
    }
    
    public static let `default` = DeepStyle()
}
