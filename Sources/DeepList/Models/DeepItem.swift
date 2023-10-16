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
            return .group(id: id, name: name, items: items, isExpanded: isExpanded)
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
