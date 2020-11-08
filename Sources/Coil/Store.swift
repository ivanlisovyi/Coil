//
//  Store.swift
//  
//
//  Created by Ivan Lisovyi on 16.03.20.
//

import Foundation
import Darwin.os.lock

protocol Store: AnyObject {
  var factories: [ObjectIdentifier: () -> Any] { get }

  func get<Service>(for type: Service.Type) -> Service?
  func set<Service>(_ factory: @escaping () -> Service, for type: Service.Type)

  func combine(_ other: Store) -> Store
}

final class ContainerStore: Store {
  var factories: [ObjectIdentifier: () -> Any]
  var instances: [ObjectIdentifier: Any]

  private var lock = os_unfair_lock()

  init(
    factories: [ObjectIdentifier: () -> Any] = [:],
    instances: [ObjectIdentifier: Any] = [:]
  ) {
    self.factories = factories
    self.instances = instances
  }

  func get<Service>(for type: Service.Type) -> Service? {
    defer { os_unfair_lock_unlock(&lock) }

    os_unfair_lock_lock(&lock)

    let key = ObjectIdentifier(type)
    if let service = instances[key] as? Service {
      return service
    }

    guard let factory = factories[key], let service = factory() as? Service else {
      return nil
    }

    instances[key] = service

    return service
  }

  func set<Service>(_ factory: @escaping () -> Service, for type: Service.Type) {
    os_unfair_lock_lock(&lock)
    factories[ObjectIdentifier(type)] = factory
    os_unfair_lock_unlock(&lock)
  }

  func combine(_ other: Store) -> Store {
    ContainerStore(factories: factories.merging(other.factories) { $1 })
  }
}

final class TransientStore: Store {
  var factories: [ObjectIdentifier: () -> Any]

  private var lock = os_unfair_lock()

  init(factories: [ObjectIdentifier: () -> Any] = [:]) {
    self.factories = factories
  }

  func get<Service>(for type: Service.Type) -> Service? {
    guard let factory = factories[ObjectIdentifier(type)], let service = factory() as? Service else {
      return nil
    }

    return service
  }

  public func set<Service>(_ factory: @escaping () -> Service, for type: Service.Type) {
    os_unfair_lock_lock(&lock)
    factories[ObjectIdentifier(type)] = factory
    os_unfair_lock_unlock(&lock)
  }

  func combine(_ other: Store) -> Store {
    TransientStore(factories: factories.merging(other.factories) { $1 })
  }
}
