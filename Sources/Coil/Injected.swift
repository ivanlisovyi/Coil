//
//  Injected.swift
//  
//
//  Created by Ivan Lisovyi on 16.03.20.
//

@propertyWrapper
public struct Injected<Service> {
    private var service: Service?
    
    public init() {}
    
    public var wrappedValue: Service {
        preconditionFailure(
            """
            An instance of \(String(describing: Service.self)) could not be injected.
            @Injected property wrappers could only be used inside classes.
            """
        )
    }
    
    public static subscript<EnclosingType: ResolverProvider>(
        _enclosingInstance enclosing: EnclosingType,
        wrapped wrappedKeyPath: KeyPath<EnclosingType, Service>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) -> Service {
        if let value = enclosing[keyPath: storageKeyPath].service {
            return value
        }
        
        guard let newValue = enclosing.resolver.resolve(Service.self) else {
            preconditionFailure(
                """
                An instance of \(String(describing: Service.self)) was not found in \(enclosing.resolver).
                This error most-likely means that the instance \(String(describing: Service.self))
                has not been registered within a dependency container used to resolve this dependency.
                """
            )
        }
        
        enclosing[keyPath: storageKeyPath].service = newValue
        return newValue
    }
}
