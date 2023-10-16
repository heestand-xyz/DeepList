import SwiftUI

public struct DeepListView<T: DeepItemProtocol, Content: View>: View {
    
    let items: [T]
    let content: (T) -> Content
    
    public init(items: [T],
                content: @escaping (T) -> Content) {
        self.items = items
        self.content = content
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 0.0) {
            
            ForEach(items) { item in
                
                DeepItemView(item: item, content: content)
            }
        }
    }
}
