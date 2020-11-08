//
//  Store.swift
//  
//
//  Created by Ivan Lisovyi on 16.03.20.
//

import Foundation
import Darwin.os.lock

protocol Store: AnyObject {
  var dependencies: [ObjectIdentifier: Dependency] { get }

  func get<Value>(for type: Value.Type, resolver: Resolver) -> Value?
  func set(_ dependency: Dependency)

  func combine(_ other: Store) -> Store
}

final class ContainerStore: Store {
  var dependencies: [ObjectIdentifier: Dependency]
  var resolvedInstances: [ObjectIdentifier: Any]

  private var lock = os_unfair_lock()

  init(
    dependencies: [ObjectIdentifier: Dependency] = [:],
    resolvedInstances: [ObjectIdentifier: Any] = [:]
  ) {
    self.dependencies = dependencies
    self.resolvedInstances = resolvedInstances
  }

  func get<Value>(for type: Value.Type, resolver: Resolver) -> Value? {
    defer { os_unfair_lock_unlock(&lock) }

    os_unfair_lock_lock(&lock)

    let key = ObjectIdentifier(type)
    if let value = resolvedInstances[key] as? Value {
      return value
    }

    guard let dependency = dependencies[key], let value = dependency.resolve(resolver) as? Value else {
      return nil
    }

    resolvedInstances[key] = value

    return value
  }

  func set(_ dependency: Dependency) {
    os_unfair_lock_lock(&lock)
    dependencies[dependency.id] = dependency
    os_unfair_lock_unlock(&lock)
  }

  func combine(_ other: Store) -> Store {
    ContainerStore(dependencies: dependencies.merging(other.dependencies) { $1 })
  }
}

final class TransientStore: Store {
  var dependencies: [ObjectIdentifier: Dependency]

  private var lock = os_unfair_lock()

  init(dependencies: [ObjectIdentifier: Dependency] = [:]) {
    self.dependencies = dependencies
  }

  func get<Value>(for type: Value.Type, resolver: Resolver) -> Value? {
    guard let dependency = dependencies[ObjectIdentifier(type)],
          let value = dependency.resolve(resolver) as? Value else {
      return nil
    }

    return value
  }

  public func set(_ dependency: Dependency) {
    os_unfair_lock_lock(&lock)
    dependencies[dependency.id] = dependency
    os_unfair_lock_unlock(&lock)
  }

  func combine(_ other: Store) -> Store {
    TransientStore(dependencies: dependencies.merging(other.dependencies) { $1 })
  }
}
