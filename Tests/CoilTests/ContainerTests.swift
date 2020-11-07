//
//  ContainerTests.swift
//
//
//  Created by Ivan Lisovyi on 16.03.20.
//

import XCTest
@testable import Coil

final class ContainerTests: XCTestCase {
  func testResolveRegisteredService() {
    // Given
    let container = Container()
      .register(SimpleProtocol.self) { _ in SimpleService() }

    // When
    let resolved = container.resolve(SimpleProtocol.self)

    // Then
    XCTAssertNotNil(resolved)
  }

  func testResolveMultipleRegisteredServices() {
    // Given
    let container = Container()
      .register(SimpleProtocol.self, factory: SimpleService())
      .register(AnotherSimpleService.self, factory: AnotherSimpleService())

    // When
    let first = container.resolve(SimpleProtocol.self)
    let second = container.resolve(AnotherSimpleService.self)

    // Then
    XCTAssertNotNil(first)
    XCTAssertNotNil(second)
  }

  func testResolveWithParentContainer() {
    // Given
    let parent = Container()
      .register(SimpleProtocol.self, factory: SimpleService())

    let container = Container(parent)
      .register(AnotherSimpleService.self, factory: AnotherSimpleService())

    // When
    let first = container.resolve(SimpleProtocol.self)
    let second = container.resolve(AnotherSimpleService.self)

    // Then
    XCTAssertNotNil(first)
    XCTAssertNotNil(second)
  }

  func testResolveWithContainerScope() {
    // Given
    let container = Container()
      .register(SimpleProtocol.self, factory: SimpleService())

    // When
    let first = container.resolve(SimpleProtocol.self)
    let second = container.resolve(SimpleProtocol.self)

    // Then
    XCTAssertNotNil(first)
    XCTAssertNotNil(second)

    XCTAssertTrue(first === second)
  }

  func testResolveWithTransientScope() {
    // Given
    let container = Container()
      .register(SimpleProtocol.self, scope: .transient, factory: SimpleService())

    // When
    let first = container.resolve(SimpleProtocol.self)
    let second = container.resolve(SimpleProtocol.self)

    // Then
    XCTAssertNotNil(first)
    XCTAssertNotNil(second)

    XCTAssertTrue(first !== second)
  }

  func testResolveWithNonRegisteredService() {
    // Given
    let container = Container()

    // When
    let resolved = container.resolve(SimpleProtocol.self)

    // Then
    XCTAssertNil(resolved)
  }

  static var allTests = [
    ("testResolveServiceRegisteredService", testResolveRegisteredService),
    ("testResolveMultipleRegisteredServices", testResolveMultipleRegisteredServices),
    ("testResolveWithParentContainer", testResolveWithParentContainer),
    ("testResolveWithContainerScope", testResolveWithContainerScope),
    ("testResolveWithTransientScope", testResolveWithTransientScope),
    ("testResolveWithNonRegisteredService", testResolveWithNonRegisteredService)
  ]
}

private protocol SimpleProtocol: AnyObject {
  var value: String { get }
}

private final class SimpleService: SimpleProtocol {
  let value = "Value"
}

private final class AnotherSimpleService {
  let value = "AnotherValue"
}
