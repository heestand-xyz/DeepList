import SwiftUI

public struct DeepItemView<T: DeepItemProtocol, Content: View>: View {
    
    let item: T
    let content: (T) -> Content
    
    public init(item: T,
                content: @escaping (T) -> Content) {
        self.item = item
        self.content = content
    }
    
    public var body: some View {
        
        ZStack {
            
            Group {
                switch item.representation {
                case .group(_, _, let items, let isExpanded):
                    
                    VStack(alignment: .leading, spacing: 0.0) {
                    
                        content(item)
                        
                        if isExpanded {
                            
                            DeepListView(items: items, content: content)
                        }
                    }
                    
                case .element:
                    
                    content(item)
                }
            }
        }
    }
}
