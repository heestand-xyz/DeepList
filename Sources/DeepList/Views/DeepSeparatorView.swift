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
    let parentItem: DI
    let deepPlace: DeepPlace
    let isGroup: Bool
    let isExpanded: Bool
//    let isNew: Bool
//    let isRecursive: Bool
    
    private var isRoot: Bool {
        rootItem == parentItem
    }
    
    private var depth: Int {
        rootItem.items.depth(for: deepPlace) ?? 0
    }
    
    private var isUnderGroup: Bool {
        rootItem.items.isUnderGroup(for: deepPlace) ?? false
    }
    
    private var isOverGroup: Bool {
        rootItem.items.isOverGroup(for: deepPlace) ?? false
    }
    
    private var isAfterGroup: Bool {
        if case .below(_, let after) = deepPlace {
            return after
        }
        return false
    }
    
    private var isOneLevelUp: Bool {
        (!isRoot && isAfterGroup && isGroup && isExpanded) || isOverGroup
    }
    
    var body: some View {
        Capsule()
            .frame(height: style.separatorHeight)
            .offset(y: {
                switch deepPlace {
                case .bottom, .above:
                    -style.separatorHeight / 2
                case .top, .below:
                    style.separatorHeight / 2
                }
            }())
            .foregroundColor(.accentColor)
//            .foregroundColor(isRecursive ? .red : isNew ? .accentColor : .primary.opacity(0.25))
            .padding(.horizontal, isOneLevelUp ? -style.indentationPadding : 0.0)
            .allowsHitTesting(false)
    }
}
