//
//  InjectedTests.swift
//  
//
//  Created by Ivan Lisovyi on 16.03.20.
//

import XCTest
@testable import Coil

final class InjectedTests: XCTestCase, Resolver {
    var resolver: Resolving {
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
    
    static var allTests = [
        ("testInjection", testInjection)
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
