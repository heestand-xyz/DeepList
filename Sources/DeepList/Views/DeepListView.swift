import SwiftUI

struct DeepListView<DI: DeepItemProtocol & ObservableObject, DD: DeepDraggable, Content: View>: View {
    
    let style: DeepStyle
    @ObservedObject var rootItem: DI
    let items: [DI]
    let drag: (DI) -> DD
    let drop: ([DD], DeepPlace, CGPoint) -> Bool
    let content: (DI) -> Content
    
    var body: some View {
        
        if !items.isEmpty {
            
            ZStack {

                RoundedRectangle(cornerRadius: style.listCornerRadius)
                    .foregroundColor(style.backgroundColor)
                    .layoutPriority(-1)
                
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
//            .padding(.vertical, style.listPadding)
        }
    }
}
