import SwiftUI

struct DeepListView<DI: DeepItemProtocol, DD: DeepDraggable, Content: View>: View {
    
    let style: DeepStyle
    let rootItem: DI
    let items: [DI]
    let drag: (DI) -> DD
    let drop: ([DD], DeepPlace, CGPoint) -> Bool
    let content: (DI) -> Content
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0.0) {
            
            ForEach(items) { item in
                
                DeepItemView(style: style,
                             rootItem: rootItem,
                             item: item,
                             drag: drag,
                             drop: drop,
                             content: content)
            }
        }
    }
}
