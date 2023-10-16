import Foundation

public enum DeepPlace {
   
    case above(itemID: UUID)
    case below(itemID: UUID)
    case bottom
    
    public var itemID: UUID? {
        switch self {
        case .above(let itemID):
            return itemID
        case .below(let itemID):
            return itemID
        case .bottom:
            return nil
        }
    }
}
