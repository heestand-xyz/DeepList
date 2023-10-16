import Foundation

public indirect enum DeepItemRepresentation<T: DeepItemProtocol> {
    case group(id: UUID, name: String, items: [T], isExpanded: Bool)
    case element(id: UUID)
}
