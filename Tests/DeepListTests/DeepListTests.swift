import XCTest
@testable import DeepList

final class DeepListTests: XCTestCase {
    
    let elementA1: DeepItem = .element(id: UUID())
    let elementA2: DeepItem = .element(id: UUID())
    let elementA3: DeepItem = .element(id: UUID())
    lazy var groupA: DeepItem = .group(id: UUID(), name: "Group A", items: [
        elementA1, elementA2, elementA3
    ], isExpanded: false)
        
    let elementBX1: DeepItem = .element(id: UUID())
    let elementBX2: DeepItem = .element(id: UUID())
    let elementBX3: DeepItem = .element(id: UUID())
    lazy var groupBX: DeepItem = .group(id: UUID(), name: "Group X", items: [
        elementBX1, elementBX2, elementBX3
    ], isExpanded: true)
    let elementBY: DeepItem = .element(id: UUID())
    let elementBZ: DeepItem = .element(id: UUID())
    lazy var groupB: DeepItem = .group(id: UUID(), name: "Group B", items: [
        groupBX, elementBY, elementBZ
    ], isExpanded: true)
    
    lazy var groupC: DeepItem = .group(id: UUID(), name: "Group C", items: [
    ], isExpanded: true)
    
    let elementD: DeepItem = .element(id: UUID())
    
    lazy var root: DeepItem = .group(id: UUID(), name: "Root", items: [
        groupA, groupB, groupC, elementD
    ], isExpanded: true)
    
    func testCount() {
        
        XCTAssertEqual(13, root.items.deepCount(target: .all, onlyExpanded: false))
        XCTAssertEqual(10, root.items.deepCount(target: .all, onlyExpanded: true))
        XCTAssertEqual(9, root.items.deepCount(target: .elements, onlyExpanded: false))
        XCTAssertEqual(6, root.items.deepCount(target: .elements, onlyExpanded: true))
        XCTAssertEqual(4, root.items.deepCount(target: .groups, onlyExpanded: false))
        XCTAssertEqual(4, root.items.deepCount(target: .groups, onlyExpanded: true))
    }
    
    func testIndices() {
        
        XCTAssertEqual(0, groupA.deepIndex(from: root.items, onlyExpanded: false))
        XCTAssertEqual(1, elementA1.deepIndex(from: root.items, onlyExpanded: false))
        XCTAssertEqual(2, elementA2.deepIndex(from: root.items, onlyExpanded: false))
        XCTAssertEqual(3, elementA3.deepIndex(from: root.items, onlyExpanded: false))
        XCTAssertEqual(4, groupB.deepIndex(from: root.items, onlyExpanded: false))
        XCTAssertEqual(5, groupBX.deepIndex(from: root.items, onlyExpanded: false))
        XCTAssertEqual(6, elementBX1.deepIndex(from: root.items, onlyExpanded: false))
        XCTAssertEqual(7, elementBX2.deepIndex(from: root.items, onlyExpanded: false))
        XCTAssertEqual(8, elementBX3.deepIndex(from: root.items, onlyExpanded: false))
        XCTAssertEqual(9, elementBY.deepIndex(from: root.items, onlyExpanded: false))
        XCTAssertEqual(10, elementBZ.deepIndex(from: root.items, onlyExpanded: false))
        XCTAssertEqual(11, groupC.deepIndex(from: root.items, onlyExpanded: false))
        XCTAssertEqual(12, elementD.deepIndex(from: root.items, onlyExpanded: false))
    }
    
    func testIsNew() throws {

        XCTAssertTrue(groupA.isNew(place: .above(itemID: elementD.id), in: root.items) == true)
        XCTAssertTrue(groupB.isNew(place: .above(itemID: elementD.id), in: root.items) == true)
        XCTAssertFalse(groupC.isNew(place: .above(itemID: elementD.id), in: root.items) == true)
        XCTAssertTrue(groupA.isNew(place: .below(itemID: elementD.id), in: root.items) == true)
        XCTAssertTrue(elementD.isNew(place: .above(itemID: groupA.id), in: root.items) == true)
        XCTAssertTrue(elementD.isNew(place: .below(itemID: groupA.id), in: root.items) == true)
        XCTAssertFalse(elementD.isNew(place: .above(itemID: elementD.id), in: root.items) == true)
        XCTAssertFalse(elementD.isNew(place: .below(itemID: elementD.id), in: root.items) == true)
        
        XCTAssertFalse(elementD.isNew(place: .bottom, in: root.items) == true)
        XCTAssertTrue(elementA3.isNew(place: .bottom, in: root.items) == true)
        XCTAssertTrue(elementD.isNew(place: .top, in: root.items) == true)
        XCTAssertFalse(groupA.isNew(place: .top, in: root.items) == true)
    }
}
