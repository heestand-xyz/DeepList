import XCTest
@testable import DeepList

final class DeepListTests: XCTestCase {
    
    let elementA1: DeepItem = .element(id: UUID())
    let elementA2: DeepItem = .element(id: UUID())
    let elementA3: DeepItem = .element(id: UUID())
    lazy var groupA: DeepItem = .group(id: UUID(), name: "Group A", items: [
        elementA1, elementA2, elementA3
    ], isExpanded: true)
        
    let elementB: DeepItem = .element(id: UUID())
    
    lazy var root: DeepItem = .group(id: UUID(), name: "Root", items: [
        groupA, elementB
    ], isExpanded: true)
    
    func testIsNew() throws {
        XCTAssertFalse(groupA.isNew(place: .above(itemID: elementB.id), in: root.items!) == true)
        XCTAssertTrue(groupA.isNew(place: .below(itemID: elementB.id), in: root.items!) == true)
        XCTAssertTrue(elementB.isNew(place: .above(itemID: groupA.id), in: root.items!) == true)
        XCTAssertTrue(elementB.isNew(place: .below(itemID: groupA.id), in: root.items!) == true)
        XCTAssertTrue(elementB.isNew(place: .below(itemID: elementA3.id), in: root.items!) == true)
        XCTAssertFalse(elementB.isNew(place: .above(itemID: elementB.id), in: root.items!) == true)
        XCTAssertFalse(elementB.isNew(place: .below(itemID: elementB.id), in: root.items!) == true)
        XCTAssertFalse(elementB.isNew(place: .bottom, in: root.items!) == true)
        XCTAssertTrue(elementA3.isNew(place: .bottom, in: root.items!) == true)
    }
}
