//
//  Connectivity.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 11/23/25.
//

import Hyperconnectivity
import Foundation
import Combine

@MainActor
public final class Network: Observable, ObservableObject {
    private var cancellable = Set<AnyCancellable>()
   
    public static let global = Network()
    
    @Published
    public var state = Connection.loading
    
    private init() {
        setupConnectivity()
    }
    
    init(override: Connection) {
        state = override
    }

    func setupConnectivity() {
        Hyperconnectivity.Publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connection in
                guard let self else { return }
                self.state = Connection(state: connection.state)
            }
            .store(in: &cancellable)
    }
    
    public var connected: Bool {
        switch state {
        case .loading, .connected:
            return true
        default:
            return false
        }
    }
}
