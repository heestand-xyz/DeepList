import Foundation

public enum DeepPlace: Equatable {
   
    case top
    case above(itemID: UUID)
    /// `after` is only used for groups, it's essentially `!inside`.
    case below(itemID: UUID, after: Bool)
    case bottom
    
    public var itemID: UUID? {
        switch self {
        case .top:
            return nil
        case .above(let itemID):
            return itemID
        case .below(let itemID, _):
            return itemID
        case .bottom:
            return nil
        }
    }
}
