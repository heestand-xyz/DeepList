import SwiftUI

public struct DeepItemView<DI: DeepItemProtocol, DD: DeepDraggable, Content: View>: View {
    
    let item: DI
    let draggable: (DI) -> DD
    let content: (DI) -> Content
    
    public init(item: DI,
                draggable: @escaping (DI) -> DD,
                content: @escaping (DI) -> Content) {
        self.item = item
        self.draggable = draggable
        self.content = content
    }
    
    public var body: some View {
        
        ZStack {
            
            Group {
                switch item.representation {
                case .group(_, let items):
                    
                    VStack(alignment: .leading, spacing: 0.0) {
                    
                        content(item)
                            .draggable(draggable(item))
                        
                        if item.isExpanded {
                            
                            DeepListView(items: items,
                                         draggable: draggable,
                                         content: content)
                        }
                    }
                    
                case .element:
                    
                    content(item)
                        .draggable(draggable(item))
                }
            }
        }
    }
}
