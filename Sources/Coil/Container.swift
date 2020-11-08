//
//  Container.swift
//  
//
//  Created by Ivan Lisovyi on 16.03.20.
//

import Darwin.os.lock

open class Container: Register, Resolver {
  @_functionBuilder
  struct ContainerBuilder {
    static func buildBlock(_ dependency: Dependency) -> [Dependency] { [dependency] }
    static func buildBlock(_ dependencies: Dependency...) -> [Dependency] { dependencies }
    static func buildEither(first dependency: Dependency) -> [Dependency] { [dependency] }
    static func buildEither(second dependency: Dependency) -> [Dependency] { [dependency] }
  }

  private let parent: Resolver?
  private var stores: [Scope: Store]
  
  private var lock = os_unfair_lock()

  public convenience init(
    parent: Resolver? = nil,
    @ContainerBuilder _ dependencies: () -> [Dependency]
  ) {
    self.init(parent)

    dependencies().forEach { register($0) }
  }
  
  public init(_ parent: Resolver? = nil) {
    self.parent = parent
    self.stores = [:]
  }

  private init(stores: [Scope: Store]) {
    self.parent = nil
    self.stores = stores
  }

  @discardableResult
  public func register(_ dependency: Dependency) -> Self {
    store(for: dependency.scope).set(dependency)

    return self
  }
  
  public func resolve<Service>(_ type: Service.Type) -> Service? {
    var found: Service?
    for store in stores.values {
      if let value = store.get(for: type, resolver: self) {
        found = value
        break
      }
    }

    return found ?? parent?.resolve(type)
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
