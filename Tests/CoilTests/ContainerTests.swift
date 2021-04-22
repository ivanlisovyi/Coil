//
//  ContainerTests.swift
//
//
//  Created by Ivan Lisovyi on 16.03.20.
//

import XCTest
import Coil

final class ContainerTests: XCTestCase {
  func testResolveRegisteredService() {
    // Given
    let container = Container()
      .register(Dependency { _ in SimpleService() as SimpleProtocol })

    // When
    let resolved = container.resolve(SimpleProtocol.self)

    // Then
    XCTAssertNotNil(resolved)
  }

  func testResolveMultipleRegisteredServices() {
    // Given
    let container = Container()
      .register(Dependency { _ in SimpleService() as SimpleProtocol })
      .register(Dependency { _ in AnotherSimpleService() })

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
      .register(Dependency { _ in SimpleService() as SimpleProtocol })

    let container = Container(parent)
      .register(Dependency { _ in AnotherSimpleService() })

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
      .register(Dependency { _ in SimpleService() as SimpleProtocol })

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
      .register(Dependency(scope: .transient) { _ in SimpleService() as SimpleProtocol })

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

  func testCombineContainers() {
    // Given
    final class DifferentService {
      let value = "DifferentValue"
    }

    let first = Container()
      .register(Dependency { _ in SimpleService() as SimpleProtocol })

    let second = Container()
      .register(Dependency(scope: .transient) { _ in AnotherSimpleService() })

    let third = Container()
      .register(Dependency { _ in DifferentService() })

    let container = Container.combine(first, second, third)

    // When
    let firstResolved = container.resolve(SimpleProtocol.self)
    let secondResolved = container.resolve(AnotherSimpleService.self)
    let thirdResolved = container.resolve(DifferentService.self)

    // Then
    XCTAssertNotNil(firstResolved)
    XCTAssertNotNil(secondResolved)
    XCTAssertNotNil(thirdResolved)
  }

  func testCombineContainersWithServiceOfTheSameType() {
    // Given
    final class FirstService {
      let value: Int

      init(value: Int) {
        self.value = value
      }
    }

    let expectedValue = 2

    let first = Container()
      .register(Dependency { _ in FirstService(value: 1) })

    let second = Container()
      .register(Dependency { _ in FirstService(value: 2) })

    let container = Container.combine(first, second)

    // When
    let resolved = container.resolve(FirstService.self)

    // Then
    XCTAssertNotNil(resolved)
    XCTAssertEqual(resolved?.value, expectedValue)
  }

  func testResolveDependencyInAnotherDependencyRegisterClosure() {
    // Given
    final class DependentService {
      let value: String

      init(value: String) {
        self.value = value
      }
    }

    let simpleService =  SimpleService()

    let container = Container()
      .register(Dependency { _ in simpleService })
      .register(Dependency { (resolver) -> DependentService in
        let simpleService = resolver.resolve(SimpleService.self)
        guard let value = simpleService?.value else {
          fatalError("SimpleService value shall be available")
        }
        return DependentService(value: value)
      })

    // When
    let resolved = container.resolve(DependentService.self)

    // Then
    XCTAssertNotNil(resolved)
    XCTAssertEqual(resolved?.value, simpleService.value)
  }

  static var allTests = [
    ("testResolveServiceRegisteredService", testResolveRegisteredService),
    ("testResolveMultipleRegisteredServices", testResolveMultipleRegisteredServices),
    ("testResolveWithParentContainer", testResolveWithParentContainer),
    ("testResolveWithContainerScope", testResolveWithContainerScope),
    ("testResolveWithTransientScope", testResolveWithTransientScope),
    ("testResolveWithNonRegisteredService", testResolveWithNonRegisteredService),
    ("testCombineContainers", testCombineContainers),
    ("testCombineContainersWithServiceOfTheSameType", testCombineContainersWithServiceOfTheSameType)
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
