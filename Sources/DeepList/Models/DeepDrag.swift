import Foundation
import CoreGraphics

public struct DeepDrag: Equatable {
    
    public let id: UUID
    public let name: String?
    public let frame: CGRect
    public var translation: CGPoint
    
    public var position: CGPoint {
        CGPoint(x: frame.origin.x + translation.x,
                y: frame.origin.y + translation.y)
    }
    public var center: CGPoint {
        CGPoint(x: position.x + frame.size.width / 2,
                y: position.y + frame.size.height / 2)
    }
    
    public init(id: UUID, name: String? = nil, frame: CGRect, translation: CGPoint = .zero) {
        self.id = id
        self.name = name
        self.frame = frame
        self.translation = translation
    }
}
