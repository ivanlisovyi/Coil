//
//  Factory.swift
//  
//
//  Created by Ivan Lisovyi on 16.03.20.
//

public typealias Factory<Service> = (Resolver) -> Service
