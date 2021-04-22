//
//  InjectedTests.swift
//
//
//  Created by Ivan Lisovyi on 16.03.20.
//

import XCTest
import Coil

final class InjectedTests: XCTestCase, ResolverProvider {
  var resolver: Resolver {
    Container {
      Dependency { _ in SimpleService() as SimpleProtocol }
      Dependency { _ in AnotherSimpleService() }
    }
  }

  @Injected fileprivate var simpleService: SimpleProtocol
  @Injected fileprivate var anotherService: AnotherSimpleService

  func testInjection() {
    XCTAssertNotNil(simpleService)
    XCTAssertEqual(simpleService.value, "Value")

    XCTAssertNotNil(anotherService)
    XCTAssertEqual(anotherService.value, "AnotherValue")
  }

  func testProjectedValueMutation() {
    XCTAssertNotNil(simpleService)
    XCTAssertEqual(simpleService.value, "Value")

    let newValue = "2"
    $simpleService?.value = newValue

    XCTAssertEqual(simpleService.value, newValue)
  }

  func testInjectionInsideStructs() {
    let structExample = StructExample()

    XCTAssertNotNil(structExample.simpleService)
    XCTAssertEqual(structExample.simpleService.value, "Value")
  }

  static var allTests = [
    ("testInjection", testInjection),
    ("testInjectionInsideStructs", testInjectionInsideStructs)
  ]
}

private struct StructExample {
  static var resolver: Resolver {
    Container {
      Dependency { _ in SimpleService() as SimpleProtocol }
    }
  }

  @Injected(resolver: resolver) var simpleService: SimpleProtocol
}


private protocol SimpleProtocol: AnyObject {
  var value: String { get set }
}

private final class SimpleService: SimpleProtocol {
  var value = "Value"
}

private final class AnotherSimpleService {
  var value = "AnotherValue"
}
