# DeepList

Nested List with Items and Groups

## Content View

```swift
import SwiftUI
import DeepList

struct ContentView: View {
    
    @StateObject private var deepList = DeepList()
    
    @State private var rootItem = Item(name: "Root", type: .newGroup(items: [
        Item(name: "A", type: .newElement()),
        Item(name: "B", type: .newElement()),
        Item(name: "Group", type: .newGroup(items: [
            Item(name: "X", type: .newElement()),
            Item(name: "Y", type: .newElement()),
        ])),
    ]))
    
    var body: some View {
        DeepObservableRootView(deepList: deepList, rootItem: rootItem) { item in
            Item.Draggable(itemID: item.id)
        } drop: { draggable, place, location in
            guard let id = draggable.first?.itemID else { return false }
            guard let item: Item = rootItem.items.firstDeep(id: id) else { return false }
            rootItem.items.move(item: item, to: place)
            return true
        } content: { item in
            ItemView(item: item)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
```

## Item View

```swift
import SwiftUI

struct ItemView: View {
    
    let item: Item
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .opacity(0.1)
            HStack(spacing: 16) {
                if item.isGroup {
                    Button {
                        item.isExpanded.toggle()
                    } label: {
                        Image(systemName: "chevron.right")
                            .rotationEffect(item.isExpanded ? .degrees(90) : .zero)
                    }
                }
                Text(item.name)
            }
            .padding(.leading)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ItemView(item: Item(name: "Element", type: .newElement()))
        .frame(height: 40)
}

#Preview {
    ItemView(item: Item(name: "Group", type: .newGroup()))
        .frame(height: 40)
}
```

## Item Model

```swift
import Foundation
import Observation
import DeepList
import UniformTypeIdentifiers

@Observable
final class Item: DeepItemProtocol {
    
    struct Draggable: DeepDraggable {
        let itemID: UUID
        static var contentType = UTType(importedAs: "xyz.heestand.deep-float.item")
    }

    enum ItemType {
        case group(id: UUID, items: [Item])
        case element(id: UUID)
        static func newGroup(items: [Item] = []) -> ItemType {
            .group(id: UUID(), items: items)
        }
        static func newElement() -> ItemType {
            .element(id: UUID())
        }
    }
    var type: ItemType
    
    var representation: DeepItemRepresentation<Item> {
        switch type {
        case .group(let id, let items):
            return .group(id: id, items: items)
        case .element(let id):
            return .element(id: id)
        }
    }
    
    var id: UUID {
        switch type {
        case .group(let id, _):
            id
        case .element(let id):
            id
        }
    }
    
    let name: String
    
    var isExpanded: Bool = true
    
    func update(items: [Item]) {
        guard case .group(let id, _) = type else { return }
        type = .group(id: id, items: items)
    }
    
    init(name: String, type: ItemType) {
        self.name = name
        self.type = type
        self.isExpanded = isExpanded
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}
```
