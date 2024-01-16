//
//  File.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023-10-20.
//

import SwiftUI

@available(iOS 17.0, *)
struct DeepObservableSeparatorView<DI: DeepItemProtocol>: View {
    
    @ObservedObject var deepList: DeepList
    let rootItem: DI
    let parentItem: DI
    let item: DI?
    let deepPlace: DeepPlace
    let style: DeepStyle
    
    private var isNew: Bool? {
        deepList.isNew(rootItem: rootItem, at: deepPlace)
    }
    
    private var isRecursive: Bool? {
        deepList.isRecursive(rootItem: rootItem, at: deepPlace)
    }
    
    private var isAtRoot: Bool {
        rootItem == parentItem
    }
    
    private var depth: Int {
        rootItem.items.depth(for: deepPlace) ?? 0
    }
    
    private var isAboveGroup: Bool {
        rootItem.items.isAboveGroup(for: deepPlace) ?? false
    }
    
    private var isBelowGroup: Bool {
        rootItem.items.isBelowGroup(for: deepPlace) ?? false
    }
    
    private var isEmptyGroup: Bool? {
        if let item: DI, case .group(_, let items) = item.representation {
            return items.isEmpty
        }
        return nil
    }
    
    private var isAfterGroup: Bool {
        if case .below(_, let after) = deepPlace {
            return after
        }
        return false
    }
    
    private var isOneLevelUp: Bool {
        guard item?.isGroup == true else { return false }
        return isAfterGroup
        || isBelowGroup && item?.isExpanded == false
        || isAboveGroup
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
            .foregroundColor(isRecursive == true ? .red : isNew != false ? style.separatorColor : .primary.opacity(0.25))
            .padding(.horizontal, style.indentation == .horizontal && isOneLevelUp ? -style.indentationPadding : 0.0)
            .padding(.leading, style.indentation.isLeading && isBelowGroup ? style.indentationPadding : 0.0)
            .offset(z: style.indentation.isDepth && isBelowGroup ? style.indentationPadding : 0.0)
            .allowsHitTesting(false)
    }
}
