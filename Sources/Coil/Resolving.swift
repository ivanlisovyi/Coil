//
//  Resolving.swift
//
//
//  Created by Ivan Lisovyi on 16.03.20.
//

public protocol Resolving {
    func resolve<Service>(_ type: Service.Type) -> Service?
}
