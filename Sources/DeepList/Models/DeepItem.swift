import Foundation

// MARK: - Deep Item

public indirect enum DeepItem: DeepItemProtocol {
    case group(id: UUID, name: String, items: [Self], isExpanded: Bool)
    case element(id: UUID)
}

// MARK: - Representation

extension DeepItem {
    
    public var representation: DeepItemRepresentation<Self> {
        switch self {
        case .group(let id, let name, let items, let isExpanded):
            return .group(id: id, items: items)
        case .element(let id):
            return .element(id: id)
        }
    }
}

// MARK: - Identifiable

extension DeepItem {

    public var id: UUID {
        switch self {
        case .group(let id, _, _, _), .element(let id):
            id
        }
    }
}

// MARK: - Is Expanded

extension DeepItem {
    
    public var isExpanded: Bool {
        switch self {
        case .group(_, _, _, let isExpanded):
            return isExpanded
        case .element:
            return false
        }
    }
    
    public mutating func update(isExpanded: Bool) {
        switch self {
        case .group(let id, let name, let items, _):
            self = .group(id: id, name: name, items: items, isExpanded: isExpanded)
        case .element:
            break
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

// MARK: - Update Items

extension DeepItem {
    
    public mutating func update(representation: DeepItemRepresentation<DeepItem>) {
        switch representation {
        case .group(let id, let items):
            guard case .group(let _id, let name, _, let isExpanded) = self else { return }
            guard id == _id else { return }
            self = .group(id: id, name: name, items: items, isExpanded: isExpanded)
        case .element(let id):
            break
        }
    }
    
    public mutating func update(items: [Self]) {
        switch self {
        case .group(let id, let name, _, let isExpanded):
            self = .group(id: id, name: name, items: items, isExpanded: isExpanded)
        case .element:
            break
        }
    }
}
