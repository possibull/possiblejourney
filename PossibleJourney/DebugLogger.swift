import Foundation
import Combine

class DebugLogger: ObservableObject {
    static let shared = DebugLogger()
    @Published var log: String = ""

    func logMessage(_ message: String) {
        DispatchQueue.main.async {
            self.log += message + "\n"
        }
        // Optionally, still print to Xcode console if possible
        print(message)
    }
} 