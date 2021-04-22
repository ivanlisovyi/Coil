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

  private let queue = DispatchQueue(label: "com.coil.container.store.queue", attributes: .concurrent)

  init(
    dependencies: [ObjectIdentifier: Dependency] = [:],
    resolvedInstances: [ObjectIdentifier: Any] = [:]
  ) {
    self.dependencies = dependencies
    self.resolvedInstances = resolvedInstances
  }

  func get<Value>(for type: Value.Type, resolver: Resolver) -> Value? {
    var resolvedValue: Value?

    queue.sync {
      let key = ObjectIdentifier(type)
      if let value = resolvedInstances[key] as? Value {
        resolvedValue = value
      } else if let dependency = dependencies[key], let value = dependency.resolve(resolver) as? Value {
        queue.async(flags: .barrier) {
          self.resolvedInstances[key] = value
        }

        resolvedValue = value
      }
    }
    
    return resolvedValue
  }

  func set(_ dependency: Dependency) {
    queue.async(flags: .barrier) {
      self.dependencies[dependency.id] = dependency
    }
  }

  func combine(_ other: Store) -> Store {
    ContainerStore(dependencies: dependencies.merging(other.dependencies) { $1 })
  }
}

final class TransientStore: Store {
  var dependencies: [ObjectIdentifier: Dependency]

  private let queue = DispatchQueue(label: "com.coil.transient.store.queue", attributes: .concurrent)

  init(dependencies: [ObjectIdentifier: Dependency] = [:]) {
    self.dependencies = dependencies
  }

  func get<Value>(for type: Value.Type, resolver: Resolver) -> Value? {
    var resolvedValue: Value?

    queue.sync {
      let key = ObjectIdentifier(type)
      if let dependency = dependencies[key], let value = dependency.resolve(resolver) as? Value {
        resolvedValue = value
      }
    }

    return resolvedValue
  }

  public func set(_ dependency: Dependency) {
    queue.async(flags: .barrier) {
      self.dependencies[dependency.id] = dependency
    }
  }

  func combine(_ other: Store) -> Store {
    TransientStore(dependencies: dependencies.merging(other.dependencies) { $1 })
  }
}
