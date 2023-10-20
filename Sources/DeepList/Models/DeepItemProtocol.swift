import Foundation

public protocol DeepItemProtocol: Equatable, Identifiable {
    
    var id: UUID { get }
    var representation: DeepItemRepresentation<Self> { get }
    
    var isExpanded: Bool { get }
    
    mutating func update(items: [Self])
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

    public var items: [Self] {
        switch representation {
        case .group(_, let items):
            items
        case .element:
            []
        }
    }
}

// MARK: - New Place

extension DeepItemProtocol {
    
    public func isNew(place: DeepPlace, in items: [Self]) -> Bool? {
        
        if id == place.itemID {
            return false
        }
        
        if case .top = place {
            return items.first != self
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
              let placeItem: Self = items.firstDeep(id: placeItemID) else {
            return nil
        }
        
        guard let depth: Int = items.depth(for: self),
              var placeDepth: Int = items.depth(for: placeItem) else {
            return nil
        }
        
        if case .below = place,  placeItem.isGroup, placeItem.isExpanded {
            placeDepth += 1
        }
        
        if depth == placeDepth {
            let index: Int = deepIndex(from: items, onlyExpanded: true)
            let placeIndex: Int = placeItem.deepIndex(from: items, onlyExpanded: true)
            if index - 1 == placeIndex, case .below = place {
                return false
            } else if index + 1 == placeIndex, case .above = place {
                return false
            }
        }
        
        return true
    }
    
    public func isRecursive(place: DeepPlace) -> Bool {
        guard let placeItemID = place.itemID, isGroup else { return false }
        if case .below = place, placeItemID == id {
            return true
        }
        func check(items: [Self]) -> Bool {
            for item in items {
                if item.id == placeItemID {
                    return true
                }
                if item.isGroup {
                    if check(items: item.items) {
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
        guard item.isNew(place: place, in: self) == true else { return }
        guard item.isRecursive(place: place) == false else { return }
        guard remove(id: item.id) else {
            assertionFailure()
            return
        }
        guard insert(item: item, at: place) else {
            assertionFailure()
            return
        }
    }
}

// MARK: - Insert

extension Array where Element: DeepItemProtocol {

    @discardableResult
    public mutating func insert(item: Element, at place: DeepPlace) -> Bool {
        if case .top = place {
            insert(item, at: 0)
            return true
        } 
        if case .bottom = place {
            insert(item, at: count)
            return true
        }
        for (index, siblingItem) in self.enumerated() {
            guard siblingItem.id != item.id else { continue }
            if siblingItem.id == place.itemID {
                var isBelow: Bool = false
                if case .below = place {
                    isBelow = true
                }
                if isBelow, siblingItem.isGroup {
                    var items: [Element] = siblingItem.items
                    items.insert(item, at: 0)
                    self[index].update(items: items)
                } else {
                    insert(item, at: isBelow ? index + 1 : index)
                }
                return true
            }
            if siblingItem.isGroup {
                var items: [Element] = siblingItem.items
                let didInsert: Bool = items.insert(item: item, at: place)
                guard didInsert else { continue }
                self[index].update(items: items)
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
        guard let item = firstDeep(id: id) else { return false }
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
            case .group(_, let items):
                var items: [Element] = items
                let didRemove: Bool = items.removeElement(id: id)
                guard didRemove else { continue }
                self[index].update(items: items)
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
            case .group(let _id, let items):
                if _id == id {
                    remove(at: index)
                    return true
                } else {
                    var items: [Element] = items
                    let didRemove = items.removeGroup(id: id)
                    guard didRemove else { continue }
                    self[index].update(items: items)
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
            if item.isGroup, item.isExpanded {
                list(items: item.items, callback: callback)
            }
        }
    }
    
    @available(*, deprecated, renamed: "deepIndex(from:)")
    public func index(from items: [Self]) -> Int {
        deepIndex(from: items, onlyExpanded: true)
    }
    
    public func deepIndex(from items: [Self],
                          onlyExpanded: Bool) -> Int {
        var index: Int = 0
        @discardableResult
        func traverse(items: [Self]) -> Bool {
            for item in items {
                if item.id == id {
                    return true
                }
                index += 1
                if item.isGroup, onlyExpanded ? item.isExpanded : true {
                    if traverse(items: item.items) {
                        return true
                    }
                }
            }
            return false
        }
        traverse(items: items)
        return index
    }
}

// MARK: - Deep

public struct CountDeepTarget: OptionSet {
    
    public var rawValue: Int
    
    public static let groups = CountDeepTarget(rawValue: 1 << 0)
    public static let elements = CountDeepTarget(rawValue: 1 << 1)
    
    public static var all: CountDeepTarget {
        [.groups, .elements]
    }
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension Array where Element: DeepItemProtocol {
    
    public func firstDeep(id: UUID) -> Element? {
        for item in self {
            if item.id == id {
                return item
            }
            if item.isGroup, item.isExpanded {
                if let item = item.items.firstDeep(id: id) {
                    return item
                }
            }
        }
        return nil
    }
    
    public func deepCount(target: CountDeepTarget = .all,
                          onlyExpanded: Bool) -> Int {
        var count: Int = 0
        for item in self {
            if target == .all {
                count += 1
            }
            if item.isElement {
                if target == .elements {
                    count += 1
                }
            } else if item.isGroup {
                if target == .groups {
                    count += 1
                }
                if onlyExpanded {
                    guard item.isExpanded else { continue }
                }
                count += item.items.deepCount(target: target,
                                              onlyExpanded: onlyExpanded)
            }
        }
        return count
    }
    
    @available(*, deprecated, renamed: "deepCount(target:onlyExpanded:)")
    public func countDeep(withCollapsed: Bool) -> Int {
        var count: Int = 0
        for item in self {
            count += 1
            if item.isGroup {
                if !withCollapsed {
                    guard item.isExpanded else { continue }
                }
                count += item.items.countDeep(withCollapsed: withCollapsed)
            }
        }
        return count
    }
    
    @available(*, deprecated, renamed: "deepCount(target:onlyExpanded:)")
    public func countDeepGroups(withCollapsed: Bool) -> Int {
        var count: Int = 0
        for item in self {
            if item.isGroup {
                count += 1
                if !withCollapsed {
                    guard item.isExpanded else { continue }
                }
                count += item.items.countDeepGroups(withCollapsed: withCollapsed)
            }
        }
        return count
    }
    
    public func depth(for item: Element) -> Int? {
        for otherItem in self {
            if otherItem.id == item.id {
                return 0
            }
            if otherItem.isGroup {
                if let depth = otherItem.items.depth(for: item) {
                    return depth + 1
                }
            }
        }
        return nil
    }
    
    public func depth(for place: DeepPlace) -> Int? {
        if case .top = place {
            return 0
        }
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
            if otherItem.isGroup {
                if let depth = otherItem.items.depth(for: place) {
                    return depth + 1
                }
            }
        }
        return nil
    }
}
