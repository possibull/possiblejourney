import Foundation
import Combine

class ProgramAppState: ObservableObject {
    @Published var loadedProgram: Program? = ProgramStorage().load()
} 