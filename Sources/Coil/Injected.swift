//
//  Injected.swift
//  
//
//  Created by Ivan Lisovyi on 16.03.20.
//

@propertyWrapper
public struct Injected<Service> {
  public var enclosingInstance: Service?

  public init(resolver: Resolver? = nil) {
    enclosingInstance = resolver?.resolve(Service.self)
  }
  
  public var wrappedValue: Service {
    guard let value = enclosingInstance else {
      preconditionFailure(
        """
        An instance of \(String(describing: Service.self)) was not found in resolver provided during initialization.
        This error most-likely means that the instance \(String(describing: Service.self))
        has not been registered within a dependency container used to resolve this dependency.
        """
      )
    }

    return value
  }

  public var projectedValue: Service? {
    get { enclosingInstance }
    set { enclosingInstance = newValue }
  }
  
  public static subscript<EnclosingType: ResolverProvider>(
    _enclosingInstance enclosing: EnclosingType,
    wrapped wrappedKeyPath: KeyPath<EnclosingType, Service>,
    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
  ) -> Service {
    if let value = enclosing[keyPath: storageKeyPath].enclosingInstance {
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
    
    enclosing[keyPath: storageKeyPath].enclosingInstance = newValue
    return newValue
  }
}
