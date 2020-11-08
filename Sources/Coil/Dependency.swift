//
//  Dependency.swift
//  
//
//  Created by Lisovyi, Ivan on 08.11.20.
//

import Foundation

public struct Dependency: Identifiable {
  public let scope: Scope
  public let resolve: (Resolver) -> Any

  public let id: ObjectIdentifier

  init<Value>(scope: Scope = .container, resolve: @escaping (Resolver) -> Value) {
    self.id = ObjectIdentifier(Value.self)
    self.scope = scope
    self.resolve = resolve
  }
}
