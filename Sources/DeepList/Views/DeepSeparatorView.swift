//
//  File.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023-10-20.
//

import SwiftUI

struct DeepSeparatorView<DI: DeepItemProtocol>: View {
    
    let style: DeepStyle
    let rootItem: DI
    let deepPlace: DeepPlace
//    let isNew: Bool
//    let isRecursive: Bool
    
    private var depth: Int {
        rootItem.items.depth(for: deepPlace) ?? 0
    }
    
    var body: some View {
        Capsule()
            .frame(height: style.separatorHeight)
            .offset(y: {
                switch deepPlace {
                case .top:
                    -style.separatorHeight / 2
                case .above:
                    -style.separatorHeight / 2
                case .below:
                    style.separatorHeight / 2
                case .bottom:
                    style.separatorHeight / 2
                }
            }())
            .foregroundColor(.accentColor)
//            .foregroundColor(isRecursive ? .red : isNew ? .accentColor : .primary.opacity(0.25))
            .padding(.leading, style.indentationPadding * CGFloat(depth))
    }
}
