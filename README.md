# Coil
![CI](https://github.com/ivanlisovyi/Coil/workflows/CI/badge.svg)

`Coil` is a library that provides a way to inject class dependencies using Swift 5.1 feature called [Property Wrappers](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md)

**Coil** heavily relies on the *property wrappers enclosing type access* feature to automatically inject class dependencies from a provided dependency container. 

> Note: @Injected property wrapper could be used inside structs but requires to provide container explicitly, e.g. @Injected(resolver: someContainer) var someValue: SomeValueType

## Usage 

### Simple Example 
```swift
let container = Container()
    .register(Dependency { _ in SimpleService() })

final class TestClass: ResolverProvider {
    var resolver: Resolver { container }
    
    @Injected var service: SimpleService
}
```

### Slightly More Complex Example
```swift
// Container.swift 

final class Container: Resolver {
    static var `default` = Container()

    let `internal`: Coil.Container

    init() {
        `internal` = Coil.Container()
            .register(Dependency { resolver in
                FirstService(resolver)
            })
            .register(Dependency { _ in 
                SecondService()
            })
    }

    func resolve<Value>(_ type: Value.Type) -> Value? {
        `internal`.resolve(type)
    }
}

// TestClass.swift

final class TestClass {
    @Injected var first: FirstService
    @Injected var second: SecondService
    
    let resolver: Resolver 
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func doSomething() {
        print(first.value)
        second.doSomething()
    }
}

extension TestClass: ResolverProvider {} 
```

### Create Container using Swift's Function Builders feature
```swift
let container = Container {
    Dependency { _ in First() } // Register dependency of `First` type in container 
    Dependency { resolver in Second(resolver) as SecondServiceProtocol } // Register dependency of `Second` type as `SecondServiceProtocol` in container
}

final class TestClass: ResolverProvider {
    @Injected var first: First
    @Injected var second: SecondServiceProtocol
    
    let resolver: Resolver 
    
    init(resolver: Resolver = container) {
        self.resolver = resolver
    }
    
    func doSomething() {
        print(first.value)
        second.doSomething()
    }
}
```

### Combine multiple Containers 
```swift
let firstContainer = Container {
    Dependency { _ in First() } // Register dependency of `First` type in container 
}

let secondContainer = Container {
    Dependency { resolver in Second(resolver) as SecondServiceProtocol } // Register dependency of `Second` type as `SecondServiceProtocol` in container
}

let combined = Container.combine(
    firstContainer,
    secondContainer
)
```

## Installation
You can add Coil to your project using Swift Package Manager. Add the following line to the `dependencies` inside your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/ivanlisovyi/Coil", .upToNextMajor(from: "1.0.0"),
    // other dependencies here 
],
```

## License 

MIT License

Copyright (c) 2020 Ivan Lisovyi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
