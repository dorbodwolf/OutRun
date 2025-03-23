// MainScreenViewModel.swift

import Foundation

class MainScreenViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var currentDistance = 0.0
    
    private var timer: Timer?
    
    func toggleRunning() {
        isRunning.toggle()
        
        if isRunning {
            currentDistance = 0.0
            startRunning()
        } else {
            stopRunning()
        }
    }
    
    private func startRunning() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.currentDistance += 0.1 // Simulate running progress
        }
    }
    
    private func stopRunning() {
        timer?.invalidate()
        timer = nil
    }
}
