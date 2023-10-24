//
//  File.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023-10-24.
//

import Foundation

public final class DeepList: ObservableObject {
    
    @Published private(set) var draggingItemID: UUID?
    
    public init() {}
    
    public func drag(itemID: UUID) {
        DispatchQueue.main.async {
            self.draggingItemID = itemID
        }
    }
    
    public func drop() {
        DispatchQueue.main.async {
            self.draggingItemID = nil
        }
    }
    
    func isNew<DI: DeepItemProtocol>(rootItem: DI, at place: DeepPlace) -> Bool? {
        guard let id: UUID = draggingItemID else { return nil }
        guard let item: DI = rootItem.items.firstDeep(id: id) else { return nil }
        return item.isNew(place: place, in: rootItem.items)
    }
    
    func isRecursive<DI: DeepItemProtocol>(rootItem: DI, at place: DeepPlace) -> Bool? {
        guard let id: UUID = draggingItemID else { return nil }
        guard let item: DI = rootItem.items.firstDeep(id: id) else { return nil }
        return item.isRecursive(place: place)
    }
}
