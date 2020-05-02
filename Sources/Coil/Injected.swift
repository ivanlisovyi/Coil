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
    
    public var wrappedValue: Service { fatalError() }
    
    public static subscript<EnclosingType: Resolver>(
        _enclosingInstance enclosing: EnclosingType,
        wrapped wrappedKeyPath: KeyPath<EnclosingType, Service>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) -> Service {
        if let value = enclosing[keyPath: storageKeyPath].service {
            return value
        }
        
        guard let newValue = enclosing.resolver.resolve(Service.self) else {
            fatalError()
        }
        
        enclosing[keyPath: storageKeyPath].service = newValue
        return newValue
    }
}
