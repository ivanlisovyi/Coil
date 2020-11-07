//
//  InjectedTests.swift
//  
//
//  Created by Ivan Lisovyi on 16.03.20.
//

import XCTest
@testable import Coil

final class InjectedTests: XCTestCase, ResolverProvider {
  var resolver: Resolver {
    return Container()
      .register(SimpleProtocol.self) { _ in SimpleService() }
      .register(AnotherSimpleService.self) { _ in AnotherSimpleService() }
  }
  
  @Injected fileprivate var simpleService: SimpleProtocol
  @Injected fileprivate var anotherService: AnotherSimpleService
  
  func testInjection() {
    XCTAssertNotNil(simpleService)
    XCTAssertEqual(simpleService.value, "Value")
    
    XCTAssertNotNil(anotherService)
    XCTAssertEqual(anotherService.value, "AnotherValue")
  }

  func testInjectionInsideStructs() {
    let structExample = StructExample()

    XCTAssertNotNil(structExample.simpleService)
    XCTAssertEqual(structExample.simpleService.value, "Value")
  }
  
  static var allTests = [
    ("testInjection", testInjection)
  ]
}

private struct StructExample {
  static var resolver: Resolver {
    Container().register(SimpleProtocol.self, factory: { _ in SimpleService() })
  }

  @Injected(resolver: resolver) var simpleService: SimpleProtocol
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
