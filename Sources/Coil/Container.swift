//
//  Container.swift
//  
//
//  Created by Ivan Lisovyi on 16.03.20.
//

import Darwin.os.lock

open class Container: Register, Resolver {
  private let parent: Resolver?
  private var stores: [Scope: Store]
  
  private var lock = os_unfair_lock()
  
  public init(_ parent: Resolver? = nil) {
    self.parent = parent
    self.stores = [:]
  }

  private init(stores: [Scope: Store]) {
    self.parent = nil
    self.stores = stores
  }

  public func register<Service>(
    _ type: Service.Type,
    scope: Scope = .container,
    factory: @escaping Factory<Service>
  ) -> Self {
    register(type, scope: scope, factory: factory(self))
  }

  public func register<Service>(
    _ type: Service.Type,
    scope: Scope = .container,
    factory: @autoclosure @escaping () -> Service
  ) -> Self {
    store(for: scope).set(factory, for: type)

    return self
  }
  
  public func resolve<Service>(_ type: Service.Type) -> Service? {
    if let store = stores.values.first(where: { $0.get(for: type) != nil })  {
      return store.get(for: type)
    }
    
    return parent?.resolve(type)
  }
}

extension Container {
  public static func combine(_ containers: Container...) -> Container {
    Container(
      stores: containers
        .map(\.stores)
        .reduce(into: [Scope: Store]()) { acc, value in
          acc.merge(value) { $0.combine($1) }
        }
    )
  }
}

// MARK: - Private

private extension Container {
  private func store(for scope: Scope) -> Store {
    defer { os_unfair_lock_unlock(&lock) }

    os_unfair_lock_lock(&lock)

    if let store = stores[scope] {
      return store
    }

    let store = makeStore(scope)
    stores[scope] = store

    return store
  }

  private func makeStore(_ scope: Scope) -> Store {
    switch scope {
    case .container:
      return ContainerStore()
    case .transient:
      return TransientStore()
    }
  }
}
