//
//  KeyValueStoreTests.swift
//  TransactionalKeyValueStoreTests
//
//  Created by Alexander on 18.01.23.
//

import XCTest
@testable import TransactionalKeyValueStore

final class KeyValueStoreTests: XCTestCase {
    var store: KeyValueStoreType!
    
    override func setUp() {
        super.setUp()
        store = KeyValueStore()
    }
    
    func testSet() {
        store.set("foo", "123")
        XCTAssertEqual(store.get("foo"), "123")
    }
    
    func testGet() {
        store.set("foo", "123")
        XCTAssertEqual(store.get("foo"), "123")
        XCTAssertNil(store.get("nonExistentKey"))
    }
    
    func testDelete() {
        store.set("foo", "123")
        XCTAssertEqual(store.delete("foo"), "123")
        XCTAssertNil(store.get("foo"))
        XCTAssertNil(store.delete("nonExistentKey"))
    }
    
    func testCount() {
        store.set("foo1", "123")
        store.set("foo2", "123")
        store.set("foo3", "1234")
        XCTAssertEqual(store.count("123"), 2)
        XCTAssertEqual(store.count("1234"), 1)
    }
    
    func testTransaction() {
        store.beginTransaction()
        store.set("foo", "123")
        XCTAssertEqual(store.get("foo"), "123")
        XCTAssertTrue(store.rollbackTransaction())
        XCTAssertNil(store.get("foo"))
    }
    
    func testRollbackWithoutTransaction() {
        XCTAssertFalse(store.rollbackTransaction())
    }
    
    func testCommitWithoutTransaction() {
        XCTAssertFalse(store.commitTransaction())
    }
    
    func testCommitTransaction() {
        store.beginTransaction()
        store.set("foo", "456")
        XCTAssertTrue(store.commitTransaction())
        XCTAssertFalse(store.rollbackTransaction())
        XCTAssertEqual(store.get("foo"), "456")
    }
    
    func testRollbackTransaction() {
        store.set("foo", "123")
        store.set("bar", "abc")
        store.beginTransaction()
        store.set("foo", "456")
        XCTAssertEqual(store.get("foo"), "456")
        store.set("bar", "def")
        XCTAssertEqual(store.get("bar"), "def")
        XCTAssertTrue(store.rollbackTransaction())
        XCTAssertEqual(store.get("foo"), "123")
        XCTAssertEqual(store.get("bar"), "abc")
        XCTAssertFalse(store.commitTransaction())
    }
    
    func testNestedTransactions() {
        store.set("foo", "123")
        store.beginTransaction()
        store.set("bar", "456")
        store.set("foo", "456")
        store.beginTransaction()
        XCTAssertEqual(store.count("456"), 2)
        XCTAssertEqual(store.get("foo"), "456")
        store.set("foo", "789")
        XCTAssertEqual(store.get("foo"), "789")
        XCTAssertTrue(store.rollbackTransaction())
        XCTAssertEqual(store.get("foo"), "456")
        XCTAssertTrue(store.rollbackTransaction())
        XCTAssertEqual(store.get("foo"), "123")
    }
}
