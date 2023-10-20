//
//  File.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023-10-20.
//

import Foundation

public struct DeepStyle {
    
    public var rowHeight: CGFloat
    public var indentationPadding: CGFloat
    public var separatorHeight: CGFloat
    public var scrollBottomEdgeInset: CGFloat
    
    public init(
        rowHeight: CGFloat = {
#if os(macOS)
            return 30
#else
            return 40
#endif
        }(),
        indentationPadding: CGFloat = 16,
        separatorHeight: CGFloat = 3,
        scrollBottomEdgeInset: CGFloat = 0.0
    ) {
        self.rowHeight = rowHeight
        self.indentationPadding = indentationPadding
        self.separatorHeight = separatorHeight
        self.scrollBottomEdgeInset = scrollBottomEdgeInset
    }
    
    public static let `default` = DeepStyle()
}
