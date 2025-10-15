//
//  NetworkMonitor.swift
//  RickyAppCore
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import Network
import Combine
import SwiftUI

/// Monitors network connectivity status
@MainActor
public final class NetworkMonitor: ObservableObject {
    public static let shared = NetworkMonitor()

    @Published public private(set) var isConnected = true
    @Published public private(set) var connectionType: NWInterface.InterfaceType?
    @Published public private(set) var isExpensive = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.ricky.networkmonitor")

    private init() {
        startMonitoring()
    }

    deinit {
        monitor.cancel()
    }

    // MARK: - Public Methods

    /// Start monitoring network status
    nonisolated public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.updateConnectionStatus(path)
            }
        }
        monitor.start(queue: queue)
    }

    /// Stop monitoring network status
    nonisolated public func stopMonitoring() {
        monitor.cancel()
    }

    // MARK: - Private Methods

    private func updateConnectionStatus(_ path: NWPath) {
        isConnected = path.status == .satisfied
        isExpensive = path.isExpensive
        connectionType = path.availableInterfaces.first?.type

        #if DEBUG
        if isConnected {
            print("✅ Network connected via \(connectionType?.description ?? "unknown")")
        } else {
            print("❌ Network disconnected")
        }
        #endif
    }
}

// MARK: - NWInterface.InterfaceType Extension

extension NWInterface.InterfaceType {
    var description: String {
        switch self {
        case .wifi: return "WiFi"
        case .cellular: return "Cellular"
        case .wiredEthernet: return "Ethernet"
        case .loopback: return "Loopback"
        case .other: return "Other"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - Network Status View Modifier

public struct NetworkStatusBanner: View {
    @ObservedObject var networkMonitor: NetworkMonitor

    public init(networkMonitor: NetworkMonitor = .shared) {
        self.networkMonitor = networkMonitor
    }

    public var body: some View {
        Group {
            if !networkMonitor.isConnected {
                HStack {
                    Image(systemName: "wifi.slash")
                    Text("No Internet Connection")
                    Spacer()
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.red)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

// View extension for easy network banner usage
public extension View {
    func networkStatusBanner() -> some View {
        VStack(spacing: 0) {
            NetworkStatusBanner()
            self
        }
    }
}
