//
//  Register.swift
//  
//
//  Created by Ivan Lisovyi on 16.03.20.
//

public protocol Register {
  @discardableResult
  func register(_ dependency: Dependency) -> Self
}
