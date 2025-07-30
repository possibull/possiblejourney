//
//  ProgramTemplateViewModel.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import Foundation
import SwiftUI

class ProgramTemplateViewModel: ObservableObject {
    @Published var templates: [ProgramTemplate] = []
    @Published var selectedCategory: TemplateCategory?
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    
    private let storage = ProgramTemplateStorage()
    
    init() {
        loadTemplates()
    }
    
    /// Load all templates from storage
    func loadTemplates() {
        isLoading = true
        templates = storage.loadAll()
        isLoading = false
    }
    
    /// Get filtered templates based on selected category and search text
    var filteredTemplates: [ProgramTemplate] {
        var filtered = templates
        
        // Filter by category if selected
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text if provided
        if !searchText.isEmpty {
            filtered = filtered.filter { template in
                template.name.localizedCaseInsensitiveContains(searchText) ||
                template.description.localizedCaseInsensitiveContains(searchText) ||
                template.category.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    /// Get templates grouped by category
    var templatesByCategory: [TemplateCategory: [ProgramTemplate]] {
        Dictionary(grouping: filteredTemplates) { $0.category }
    }
    
    /// Get templates for a specific category
    func templates(for category: TemplateCategory) -> [ProgramTemplate] {
        return templates.filter { $0.category == category }
    }
    
    /// Create a program from a template
    func createProgram(from template: ProgramTemplate, startDate: Date? = nil, endOfDayTime: Date? = nil) -> Program {
        return template.createProgram(startDate: startDate, endOfDayTime: endOfDayTime, numberOfDays: nil)
    }
    
    /// Add a new template
    func addTemplate(_ template: ProgramTemplate) {
        storage.add(template)
        loadTemplates()
    }
    
    /// Update an existing template
    func updateTemplate(_ template: ProgramTemplate) {
        storage.update(template)
        loadTemplates()
    }
    
    /// Delete a template
    func deleteTemplate(_ template: ProgramTemplate) {
        storage.delete(template)
        loadTemplates()
    }
    
    /// Get template by ID
    func getTemplate(by id: UUID) -> ProgramTemplate? {
        return storage.get(by: id)
    }
    
    /// Clear all templates (for testing)
    func clearAllTemplates() {
        storage.clear()
        loadTemplates()
    }
    
    /// Reset to default templates
    func resetToDefaults() {
        storage.clear()
        loadTemplates() // This will recreate default templates
    }
} 