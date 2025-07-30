//
//  ProgramTemplateStorage.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import Foundation

class ProgramTemplateStorage {
    private let userDefaults = UserDefaults.standard
    private let templatesKey = "programTemplates"
    
    /// Load all saved templates
    func loadAll() -> [ProgramTemplate] {
        guard let data = userDefaults.data(forKey: templatesKey),
              let templates = try? JSONDecoder().decode([ProgramTemplate].self, from: data) else {
            // Return default templates if no saved templates exist
            return createDefaultTemplates()
        }
        return templates
    }
    
    /// Save templates to storage
    func save(_ templates: [ProgramTemplate]) {
        if let data = try? JSONEncoder().encode(templates) {
            userDefaults.set(data, forKey: templatesKey)
        }
    }
    
    /// Add a new template
    func add(_ template: ProgramTemplate) {
        var templates = loadAll()
        templates.append(template)
        save(templates)
    }
    
    /// Update an existing template
    func update(_ template: ProgramTemplate) {
        var templates = loadAll()
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            var updatedTemplate = template
            updatedTemplate.lastModified = Date()
            templates[index] = updatedTemplate
            save(templates)
        }
    }
    
    /// Create a copy of a template (makes it editable)
    func duplicate(_ template: ProgramTemplate) -> ProgramTemplate {
        let copy = ProgramTemplate(
            name: "\(template.name) (Copy)",
            description: template.description,
            category: template.category,
            defaultNumberOfDays: template.defaultNumberOfDays,
            tasks: template.tasks,
            isDefault: false
        )
        add(copy)
        return copy
    }
    
    /// Delete a template
    func delete(_ template: ProgramTemplate) {
        var templates = loadAll()
        templates.removeAll { $0.id == template.id }
        save(templates)
    }
    
    /// Get template by ID
    func get(by id: UUID) -> ProgramTemplate? {
        return loadAll().first { $0.id == id }
    }
    
    /// Get templates by category
    func getTemplates(for category: TemplateCategory) -> [ProgramTemplate] {
        return loadAll().filter { $0.category == category }
    }
    
    /// Clear all templates
    func clear() {
        userDefaults.removeObject(forKey: templatesKey)
    }
    
    /// Reset templates to default order (75Hard first)
    func resetToDefaults() {
        clear()
        _ = createDefaultTemplates()
    }
    
    /// Create default templates for first-time users
    private func createDefaultTemplates() -> [ProgramTemplate] {
        let defaultTemplates = [
            // Health & Fitness
            ProgramTemplate(
                name: "Morning Wellness",
                description: "Start your day with healthy habits",
                category: .health,
                defaultNumberOfDays: 30,
                tasks: [
                    Task(id: UUID(), title: "Drink a glass of water", description: "Hydrate first thing in the morning"),
                    Task(id: UUID(), title: "10 minutes of stretching", description: "Wake up your body gently"),
                    Task(id: UUID(), title: "Take vitamins", description: "Support your daily nutrition"),
                    Task(id: UUID(), title: "5 minutes of deep breathing", description: "Center yourself for the day")
                ],
                isDefault: true
            ),
            
            // Productivity
            ProgramTemplate(
                name: "Daily Focus",
                description: "Boost your productivity with structured habits",
                category: .productivity,
                defaultNumberOfDays: 21,
                tasks: [
                    Task(id: UUID(), title: "Review daily goals", description: "Plan your most important tasks"),
                    Task(id: UUID(), title: "Clear workspace", description: "Organize your environment"),
                    Task(id: UUID(), title: "Time block 2 hours", description: "Focus on deep work"),
                    Task(id: UUID(), title: "Review progress", description: "Reflect on what you accomplished")
                ],
                isDefault: true
            ),
            
            // Learning
            ProgramTemplate(
                name: "Skill Building",
                description: "Dedicate time to learning something new",
                category: .learning,
                defaultNumberOfDays: 60,
                tasks: [
                    Task(id: UUID(), title: "Read for 20 minutes", description: "Expand your knowledge"),
                    Task(id: UUID(), title: "Practice a skill", description: "Work on improving a specific ability"),
                    Task(id: UUID(), title: "Take notes", description: "Document what you learned"),
                    Task(id: UUID(), title: "Apply knowledge", description: "Use what you learned in practice")
                ],
                isDefault: true
            ),
            
            // Mindfulness
            ProgramTemplate(
                name: "Mindful Living",
                description: "Cultivate awareness and presence",
                category: .mindfulness,
                defaultNumberOfDays: 30,
                tasks: [
                    Task(id: UUID(), title: "5-minute meditation", description: "Practice mindfulness"),
                    Task(id: UUID(), title: "Express gratitude", description: "Write down 3 things you're thankful for"),
                    Task(id: UUID(), title: "Mindful eating", description: "Eat one meal without distractions"),
                    Task(id: UUID(), title: "Nature connection", description: "Spend time outdoors or with plants")
                ],
                isDefault: true
            ),
            
            // Relationships
            ProgramTemplate(
                name: "Connection Building",
                description: "Strengthen your relationships",
                category: .relationships,
                defaultNumberOfDays: 30,
                tasks: [
                    Task(id: UUID(), title: "Reach out to someone", description: "Call, text, or message a friend or family member"),
                    Task(id: UUID(), title: "Active listening", description: "Have a conversation where you truly listen"),
                    Task(id: UUID(), title: "Express appreciation", description: "Tell someone why you value them"),
                    Task(id: UUID(), title: "Quality time", description: "Spend focused time with a loved one")
                ],
                isDefault: true
            ),
            
            // Finance
            ProgramTemplate(
                name: "Financial Wellness",
                description: "Build healthy money habits",
                category: .finance,
                defaultNumberOfDays: 30,
                tasks: [
                    Task(id: UUID(), title: "Track expenses", description: "Record your spending for the day"),
                    Task(id: UUID(), title: "Review budget", description: "Check your financial plan"),
                    Task(id: UUID(), title: "Save something", description: "Put aside money, even if it's small"),
                    Task(id: UUID(), title: "Financial education", description: "Learn about money management")
                ],
                isDefault: true
            ),
            
            // 75Hard Challenge (last so it appears first in the list)
            ProgramTemplate(
                name: "75Hard",
                description: "A 75-day mental toughness and fitness challenge",
                category: .health,
                defaultNumberOfDays: 75,
                tasks: [
                    Task(id: UUID(), title: "Follow a diet", description: "Choose a diet and stick to it - no cheat meals"),
                    Task(id: UUID(), title: "No cheat meals and no alcohol", description: "Stick to your chosen diet with zero exceptions and complete abstinence from alcohol"),
                    Task(id: UUID(), title: "Indoor workout (45 minutes)", description: "Complete a 45-minute workout indoors"),
                    Task(id: UUID(), title: "Outdoor workout (45 minutes)", description: "Complete a 45-minute workout outdoors, regardless of weather"),
                    Task(id: UUID(), title: "Drink 1 gallon of water", description: "Stay hydrated throughout the day"),
                    Task(id: UUID(), title: "Read 10 pages", description: "Read from a non-fiction book"),
                    Task(id: UUID(), title: "Take a progress photo", description: "Document your journey daily")
                ],
                isDefault: true
            )
        ]
        
        // Save default templates
        save(defaultTemplates)
        return defaultTemplates
    }
} 