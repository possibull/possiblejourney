import Foundation

struct ProgramStorage {
    private let key = "SavedProgram"
    
    func save(_ program: Program) {
        if let data = try? JSONEncoder().encode(program) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func load() -> Program? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        let program = try? JSONDecoder().decode(Program.self, from: data)
        return program
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
} 