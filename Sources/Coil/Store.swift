//
//  Store.swift
//  
//
//  Created by Ivan Lisovyi on 16.03.20.
//

import Foundation
import Darwin.os.lock

protocol Store: AnyObject {
    func get<Service>(for type: Service.Type) -> Service?
    func set<Service>(_ factory: @escaping () -> Service, for type: Service.Type)
}

final class ContainerStore: Store {
    private var instances = [ObjectIdentifier: Any]()
    private var factories = [ObjectIdentifier: () -> Any]()
    
    private var lock = os_unfair_lock()
    
    public func get<Service>(for type: Service.Type) -> Service? {
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
    
    public func set<Service>(_ factory: @escaping () -> Service, for type: Service.Type) {
        factories[ObjectIdentifier(type)] = factory
    }
}

final class TransientStore: Store {
    private var factories = [ObjectIdentifier: () -> Any]()
    
    public func get<Service>(for type: Service.Type) -> Service? {
        guard let factory = factories[ObjectIdentifier(type)], let service = factory() as? Service else {
            return nil
        }
        
        return service
    }
    
    public func set<Service>(_ factory: @escaping () -> Service, for type: Service.Type) {
        factories[ObjectIdentifier(type)] = factory
    }
}
