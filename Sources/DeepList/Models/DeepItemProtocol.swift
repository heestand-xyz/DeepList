import Foundation

public protocol DeepItemProtocol: Codable, Equatable, Identifiable {
    var id: UUID { get }
    var representation: DeepItemRepresentation<Self> { get }
    static func group(id: UUID, name: String, items: [Self], isExpanded: Bool) -> Self
    static func element(id: UUID) -> Self
}

// MARK: - Is

extension DeepItemProtocol {

    public var isGroup: Bool {
        if case .group = representation {
            return true
        }
        return false
    }
    
    public var isElement: Bool {
        if case .element = representation {
            return true
        }
        return false
    }
}

// MARK: - Items

extension DeepItemProtocol {

    public var items: [Self]? {
        switch representation {
        case .group(_, _, let items, _):
            items
        case .element:
            nil
        }
    }
}

// MARK: - Name

extension DeepItemProtocol {

    public var name: String? {
        switch representation {
        case .group(_, let name, _, _):
            return name
        case .element:
            return nil
        }
    }
    
    public mutating func update(name: String) {
        switch representation {
        case .group(let id, _, let items, let isExpanded):
            self = .group(id: id, name: name, items: items, isExpanded: isExpanded)
        case .element:
            break
        }
    }
}

// MARK: - Update Is Expanded

extension DeepItemProtocol {
    
    public mutating func update(isExpanded: Bool) {
        switch representation {
        case .group(let id, let name, let items, _):
            self = .group(id: id, name: name, items: items, isExpanded: isExpanded)
        case .element:
            break
        }
    }
}

// MARK: - Update Items

extension DeepItemProtocol {
    
    public mutating func update(items: [Self]) {
        switch representation {
        case .group(let id, let name, _, let isExpanded):
            self = .group(id: id, name: name, items: items, isExpanded: isExpanded)
        case .element:
            break
        }
    }
}

// MARK: - New Place

extension DeepItemProtocol {
    
    public func isNew(place: DeepPlace, in items: [Self]) -> Bool? {
        
        if id == place.itemID {
            return false
        }
        
        if case .bottom = place {
            return items.last != self
        }
        
        if case .above(let itemID) = place {
            if case .group = representation,
               let index = items.firstIndex(of: self),
               index < items.count - 1 {
                let nextItem: Self = items[index + 1]
                if nextItem.id == itemID {
                    return false
                }
            }
        }
        
        guard let placeItemID: UUID = place.itemID,
              let placeItem: Self = items.firstDeep(id: placeItemID)
        else { return nil }
        
        guard let depth: Int = items.depth(for: self),
              var placeDepth: Int = items.depth(for: placeItem)
        else { return nil }
        
        if case .below = place, case .group(_, _, _, let isExpanded) = placeItem.representation,
           isExpanded {
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
              case .group(_, _, let items, _) = representation
        else { return false }
        if case .below = place, placeItemID == id {
            return true
        }
        func check(items: [Self]) -> Bool {
            for item in items {
                if item.id == placeItemID {
                    return true
                }
                if case .group(_, _, let items, _) = item.representation {
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

extension Array where Element: DeepItemProtocol {
    
    public mutating func move(item: Element, to place: DeepPlace) {
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

extension Array where Element: DeepItemProtocol {

    @discardableResult
    public mutating func insert(item: Element, at place: DeepPlace) -> Bool {
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
                   case .group(let id, let name, let items, let isExpanded) = siblingItem.representation {
                    var items: [Element] = items
                    items.insert(item, at: 0)
                    let groupItem: Element = .group(id: id, name: name, items: items, isExpanded: isExpanded)
                    self[index] = groupItem
                } else {
                    insert(item, at: isBelow ? index + 1 : index)
                }
                return true
            }
            if case .group(let id, let name, let items, let isExpanded) = siblingItem.representation {
                var items: [Element] = items
                let didInsert: Bool = items.insert(item: item, at: place)
                guard didInsert
                else { continue }
                let groupItem: Element = .group(id: id, name: name, items: items, isExpanded: isExpanded)
                self[index] = groupItem
                return true
            }
        }
        return false
    }
}

// MARK: - Remove

extension Array where Element: DeepItemProtocol {
    
    @discardableResult
    public mutating func remove(id: UUID) -> Bool {
        guard let item = firstDeep(id: id)
        else { return false }
        switch item.representation {
        case .group:
            return removeGroup(id: id)
        case .element:
            return removeElement(id: id)
        }
    }
    
    @discardableResult
    public mutating func removeElement(id: UUID) -> Bool {
        for (index, item) in self.enumerated() {
            switch item.representation {
            case .element(let _id):
                if _id == id {
                    remove(at: index)
                    return true
                }
            case .group(let _id, let name, let items, let isExpanded):
                var items: [Element] = items
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
            switch item.representation {
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

extension DeepItemProtocol {
    
    public static func list(items: [Self], callback: (Self) -> ()) {
        for item in items {
            callback(item)
            if case .group(_, _, let items, let isExpanded) = item.representation,
               isExpanded {
                list(items: items, callback: callback)
            }
        }
    }
    
    public func index(from items: [Self]) -> Int {
        var index: Int = 0
        @discardableResult
        func list(items: [Self]) -> Bool {
            for item in items {
                if item.id == id {
                    return true
                }
                index += 1
                if case .group(_, _, let items, let isExpanded) = item.representation,
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

extension Array where Element: DeepItemProtocol {
    
    public func firstDeep(id: UUID) -> Element? {
        for item in self {
            if item.id == id {
                return item
            }
            if case .group(_, _, let items, let isExpanded) = item.representation,
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
            if case .group(_, _, let items, let isExpanded) = item.representation {
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
            if case .group(_, _, let items, let isExpanded) = item.representation {
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
    
    public func depth(for item: Element) -> Int? {
        for otherItem in self {
            if otherItem.id == item.id {
                return 0
            }
            if case .group(_, _, let items, _) = otherItem.representation {
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
                   case .group = otherItem.representation {
                    return 1
                }
                return 0
            }
            if case .group(_, _, let items, _) = otherItem.representation {
                if let depth = items.depth(for: place) {
                    return depth + 1
                }
            }
        }
        return nil
    }
}
