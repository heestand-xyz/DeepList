import XCTest
@testable import DeepList

final class DeepListTests: XCTestCase {
    
    struct All {
        
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
    }
    
    var all: All!
    
    override func setUp() async throws {
        all = All()
    }
    
    func testCount() {
        
        XCTAssertEqual(13, all.root.items.deepCount(target: .all, expansion: .all))
        XCTAssertEqual(10, all.root.items.deepCount(target: .all, expansion: .open))
        XCTAssertEqual(9, all.root.items.deepCount(target: .elements, expansion: .all))
        XCTAssertEqual(6, all.root.items.deepCount(target: .elements, expansion: .open))
        XCTAssertEqual(4, all.root.items.deepCount(target: .groups, expansion: .all))
        XCTAssertEqual(4, all.root.items.deepCount(target: .groups, expansion: .open))
    }
    
    func testIndices() {
        
        XCTAssertEqual(0, all.groupA.deepIndex(from: all.root.items, expansion: .all))
        XCTAssertEqual(1, all.elementA1.deepIndex(from: all.root.items, expansion: .all))
        XCTAssertEqual(2, all.elementA2.deepIndex(from: all.root.items, expansion: .all))
        XCTAssertEqual(3, all.elementA3.deepIndex(from: all.root.items, expansion: .all))
        XCTAssertEqual(4, all.groupB.deepIndex(from: all.root.items, expansion: .all))
        XCTAssertEqual(5, all.groupBX.deepIndex(from: all.root.items, expansion: .all))
        XCTAssertEqual(6, all.elementBX1.deepIndex(from: all.root.items, expansion: .all))
        XCTAssertEqual(7, all.elementBX2.deepIndex(from: all.root.items, expansion: .all))
        XCTAssertEqual(8, all.elementBX3.deepIndex(from: all.root.items, expansion: .all))
        XCTAssertEqual(9, all.elementBY.deepIndex(from: all.root.items, expansion: .all))
        XCTAssertEqual(10, all.elementBZ.deepIndex(from: all.root.items, expansion: .all))
        XCTAssertEqual(11, all.groupC.deepIndex(from: all.root.items, expansion: .all))
        XCTAssertEqual(12, all.elementD.deepIndex(from: all.root.items, expansion: .all))
    }
    
    func testIsNew() throws {

        XCTAssertTrue(all.groupA.isNew(place: .above(itemID: all.elementD.id), in: all.root.items) == true)
        XCTAssertTrue(all.groupB.isNew(place: .above(itemID: all.elementD.id), in: all.root.items) == true)
        XCTAssertFalse(all.groupC.isNew(place: .above(itemID: all.elementD.id), in: all.root.items) == true)
        XCTAssertTrue(all.groupA.isNew(place: .below(itemID: all.elementD.id, after: false), in: all.root.items) == true)
        XCTAssertTrue(all.elementD.isNew(place: .above(itemID: all.groupA.id), in: all.root.items) == true)
        XCTAssertTrue(all.elementD.isNew(place: .below(itemID: all.groupA.id, after: false), in: all.root.items) == true)
        XCTAssertFalse(all.elementD.isNew(place: .above(itemID: all.elementD.id), in: all.root.items) == true)
        XCTAssertFalse(all.elementD.isNew(place: .below(itemID: all.elementD.id, after: false), in: all.root.items) == true)
        
        XCTAssertFalse(all.elementD.isNew(place: .bottom, in: all.root.items) == true)
        XCTAssertTrue(all.elementA3.isNew(place: .bottom, in: all.root.items) == true)
        XCTAssertTrue(all.elementD.isNew(place: .top, in: all.root.items) == true)
        XCTAssertFalse(all.groupA.isNew(place: .top, in: all.root.items) == true)
    }
}
