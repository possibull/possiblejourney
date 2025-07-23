import Foundation

struct ProgramStorage {
    private let key = "SavedProgram"
    
    func save(_ program: Program) {
        print("DEBUG: Saving program: \(program)")
        if let data = try? JSONEncoder().encode(program) {
            UserDefaults.standard.set(data, forKey: key)
            print("DEBUG: Program data saved to UserDefaults")
        } else {
            print("DEBUG: Failed to encode program")
        }
    }
    
    func load() -> Program? {
        print("DEBUG: ProgramStorage.load() called")
        guard let data = UserDefaults.standard.data(forKey: key) else {
            print("DEBUG: No data found for key \(key)")
            return nil
        }
        let program = try? JSONDecoder().decode(Program.self, from: data)
        print("DEBUG: Loaded program: \(String(describing: program))")
        return program
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
} 