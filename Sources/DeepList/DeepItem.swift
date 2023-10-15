import Foundation

public indirect enum DeepItem: Codable, Equatable {
    case group(id: UUID, name: String, items: [DeepItem], isExpanded: Bool)
    case element(id: UUID)
}

// MARK: - Identifiable

extension DeepItem: Identifiable {

    public var id: UUID {
        switch self {
        case .group(let id, _, _, _), .element(let id):
            id
        }
    }
}

// MARK: - Items

extension DeepItem {

    public var items: [DeepItem]? {
        switch self {
        case .group(_, _, let items, _):
            items
        case .element:
            nil
        }
    }
}

// MARK: - Name

extension DeepItem {

    public var name: String? {
        switch self {
        case .group(_, let name, _, _):
            return name
        case .element:
            return nil
        }
    }
    
    public mutating func update(name: String) {
        switch self {
        case .group(let id, _, let items, let isExpanded):
            self = .group(id: id, name: name, items: items, isExpanded: isExpanded)
        case .element:
            break
        }
    }
}

// MARK: - Update Is Expanded

extension DeepItem {
    
    public mutating func update(isExpanded: Bool) {
        switch self {
        case .group(let id, let name, let items, _):
            self = .group(id: id, name: name, items: items, isExpanded: isExpanded)
        case .element:
            break
        }
    }
}

// MARK: - Update Items

extension DeepItem {
    
    public mutating func update(items: [DeepItem]) {
        switch self {
        case .group(let id, let name, _, let isExpanded):
            self = .group(id: id, name: name, items: items, isExpanded: isExpanded)
        case .element:
            break
        }
    }
}

// MARK: - New Place

extension DeepItem {
    
    public func isNew(place: DeepPlace, in items: [DeepItem]) -> Bool? {
        
        if id == place.itemID {
            return false
        }
        
        if case .bottom = place {
            return items.last != self
        }
        
        if case .above(let itemID) = place {
            if case .group = self,
               let index = items.firstIndex(of: self),
               index < items.count - 1 {
                let nextItem: DeepItem = items[index + 1]
                if nextItem.id == itemID {
                    return false
                }
            }
        }
        
        guard let placeItemID = place.itemID,
              let placeItem = items.firstDeep(id: placeItemID)
        else { return nil }
        
        guard let depth: Int = items.depth(for: self),
              var placeDepth: Int = items.depth(for: placeItem)
        else { return nil }
        
        if case .below = place, case .group(_, _, _, let isExpanded) = placeItem, isExpanded {
            placeDepth += 1
        }
        
        if depth == placeDepth {
            let index: Int = index(from: items)
            let placeIndex: Int = placeItem.index(from: items)
            if index - 1 == placeIndex, case .below = place {
                return false
            } else if index + 1 == placeIndex, case .above = place {
                return false
            }
        }
        
        return true
    }
    
    public func isRecursive(place: DeepPlace) -> Bool {
        guard let placeItemID = place.itemID,
              case .group(_, _, let items, _) = self
        else { return false }
        if case .below = place, placeItemID == id {
            return true
        }
        func check(items: [DeepItem]) -> Bool {
            for item in items {
                if item.id == placeItemID {
                    return true
                }
                if case .group(_, _, let items, _) = item {
                    if check(items: items) {
                        return true
                    }
                }
            }
            return false
        }
        return check(items: items)
    }
}

// MARK: - Move

extension Array where Element == DeepItem {
    
    public mutating func move(item: DeepItem, to place: DeepPlace) {
        guard item.isNew(place: place, in: self) == true
        else { return }
        guard item.isRecursive(place: place) == false
        else { return }
        guard remove(id: item.id)
        else {
            assertionFailure()
            return
        }
        guard insert(item: item, at: place)
        else {
            assertionFailure()
            return
        }
    }
}

// MARK: - Insert

extension Array where Element == DeepItem {

    @discardableResult
    public mutating func insert(item: DeepItem, at place: DeepPlace) -> Bool {
        if case .bottom = place {
            insert(item, at: count)
            return true
        }
        for (index, siblingItem) in self.enumerated() {
            guard siblingItem.id != item.id
            else { continue }
            if siblingItem.id == place.itemID {
                var isBelow: Bool = false
                if case .below = place {
                    isBelow = true
                }
                if isBelow,
                    case .group(let id, let name, let items, let isExpanded) = siblingItem {
                    var items: [DeepItem] = items
                    items.insert(item, at: 0)
                    let groupItem: DeepItem = .group(id: id, name: name, items: items, isExpanded: isExpanded)
                    self[index] = groupItem
                } else {
                    insert(item, at: isBelow ? index + 1 : index)
                }
                return true
            }
            if case .group(let id, let name, let items, let isExpanded) = siblingItem {
                var items: [DeepItem] = items
                let didInsert: Bool = items.insert(item: item, at: place)
                guard didInsert
                else { continue }
                let groupItem: DeepItem = .group(id: id, name: name, items: items, isExpanded: isExpanded)
                self[index] = groupItem
                return true
            }
        }
        return false
    }
}

// MARK: - Remove

extension Array where Element == DeepItem {
    
    @discardableResult
    public mutating func remove(id: UUID) -> Bool {
        guard let item = firstDeep(id: id)
        else { return false }
        switch item {
        case .group:
            return removeGroup(id: id)
        case .element:
            return removeElement(id: id)
        }
    }
    
    @discardableResult
    public mutating func removeElement(id: UUID) -> Bool {
        for (index, item) in self.enumerated() {
            switch item {
            case .element(let _id):
                if _id == id {
                    remove(at: index)
                    return true
                }
            case .group(let _id, let name, let items, let isExpanded):
                var items: [DeepItem] = items
                let didRemove: Bool = items.removeElement(id: id)
                guard didRemove
                else { continue }
                self[index] = .group(id: _id, name: name, items: items, isExpanded: isExpanded)
                return true
            }
        }
        return false
    }
    
    @discardableResult
    public mutating func removeGroup(id: UUID) -> Bool {
        for (index, item) in self.enumerated().reversed() {
            switch item {
            case .element:
                continue
            case .group(let _id, let name, let items, let isExpanded):
                if _id == id {
                    remove(at: index)
                    return true
                } else {
                    var items = items
                    let didRemove = items.removeGroup(id: id)
                    guard didRemove
                    else { continue }
                    self[index] = .group(id: _id, name: name, items: items, isExpanded: isExpanded)
                    return true
                }
            }
        }
        return false
    }
}

// MARK: - Index

extension DeepItem {
    
    public static func list(items: [DeepItem], callback: (DeepItem) -> ()) {
        for item in items {
            callback(item)
            if case .group(_, _, let items, let isExpanded) = item,
               isExpanded {
                list(items: items, callback: callback)
            }
        }
    }
    
    public func index(from items: [DeepItem]) -> Int {
        var index: Int = 0
        @discardableResult
        func list(items: [DeepItem]) -> Bool {
            for item in items {
                if item.id == id {
                    return true
                }
                index += 1
                if case .group(_, _, let items, let isExpanded) = item,
                   isExpanded {
                    if list(items: items) {
                        return true
                    }
                }
            }
            return false
        }
        list(items: items)
        return index
    }
}

// MARK: - Deep

extension Array where Element == DeepItem {
    
    public func firstDeep(id: UUID) -> DeepItem? {
        for item in self {
            if item.id == id {
                return item
            }
            if case .group(_, _, let items, let isExpanded) = item,
               isExpanded {
                if let item = items.firstDeep(id: id) {
                    return item
                }
            }
        }
        return nil
    }
    
    public func countDeep(withCollapsed: Bool) -> Int {
        var count: Int = 0
        for item in self {
            count += 1
            if case .group(_, _, let items, let isExpanded) = item {
                if !withCollapsed {
                    guard isExpanded
                    else { continue }
                }
                count += items.countDeep(withCollapsed: withCollapsed)
            }
        }
        return count
    }
    
    public func countDeepGroups(withCollapsed: Bool) -> Int {
        var count: Int = 0
        for item in self {
            if case .group(_, _, let items, let isExpanded) = item {
                count += 1
                if !withCollapsed {
                    guard isExpanded
                    else { continue }
                }
                count += items.countDeepGroups(withCollapsed: withCollapsed)
            }
        }
        return count
    }
    
    public func depth(for item: DeepItem) -> Int? {
        for otherItem in self {
            if otherItem.id == item.id {
                return 0
            }
            if case .group(_, _, let items, _) = otherItem {
                if let depth = items.depth(for: item) {
                    return depth + 1
                }
            }
        }
        return nil
    }
    
    public func depth(for place: DeepPlace) -> Int? {
        if case .bottom = place {
            return 0
        }
        for otherItem in self {
            if otherItem.id == place.itemID {
                if case .below = place,
                   case .group = otherItem {
                    return 1
                }
                return 0
            }
            if case .group(_, _, let items, _) = otherItem {
                if let depth = items.depth(for: place) {
                    return depth + 1
                }
            }
        }
        return nil
    }
}
