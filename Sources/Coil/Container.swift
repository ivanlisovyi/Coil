//
//  Container.swift
//  
//
//  Created by Ivan Lisovyi on 16.03.20.
//

import Darwin.os.lock

public typealias ContainerProtocol = Containing & Resolving

public final class Container: ContainerProtocol {
    private let parent: Resolving?
    
    private var stores = [Scope: Store]()
    
    private var lock = os_unfair_lock()
    
    public init(_ parent: Resolving? = nil) {
        self.parent = parent
    }
    
    public func register<Service>(
        _ type: Service.Type,
        scope: Scope = .container,
        factory: @escaping Factory<Service>
    ) -> Self {
        store(for: scope).set({ factory(self) }, for: type)
        
        return self
    }
    
    public func resolve<Service>(_ type: Service.Type) -> Service? {
        if let store = stores.values.first(where: { $0.get(for: type) != nil })  {
            return store.get(for: type)
        }
        
        return parent?.resolve(type)
    }
    
    // MARK: - Private
    
    private func store(for scope: Scope) -> Store {
        if let store = stores[scope] {
            return store
        }
        
        os_unfair_lock_lock(&lock)
        
        let store = makeStore(scope)
        stores[scope] = store
        
        os_unfair_lock_unlock(&lock)
        
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
