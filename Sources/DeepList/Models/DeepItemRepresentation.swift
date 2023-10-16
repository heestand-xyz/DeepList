import Foundation

public indirect enum DeepItemRepresentation<T: DeepItemProtocol> {
    case group(id: UUID, items: [T])
    case element(id: UUID)
}
