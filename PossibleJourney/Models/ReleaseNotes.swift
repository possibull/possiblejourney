import Foundation

struct ReleaseNotes {
    let version: String
    let buildNumber: Int
    let title: String
    let notes: [String]
    let date: Date
    
    static let allReleaseNotes: [ReleaseNotes] = [
            ReleaseNotes(
                version: "1.4",
                buildNumber: 1,
                title: "Polished Modern UI Design",
                notes: [
                    "🎨 Complete UI redesign with modern, polished aesthetics",
                    "✨ Beautiful animated splash screen with gradient backgrounds",
                    "📱 Modern card-based design for all views and components",
                    "🎯 Enhanced task rows with smooth animations and better typography",
                    "🔧 Redesigned Settings view with elegant card layouts",
                    "⚡ Smooth spring animations and micro-interactions throughout",
                    "🎨 Consistent design system with rounded corners and shadows",
                    "📱 Improved visual hierarchy and spacing for better usability",
                    "🚀 Ready for TestFlight distribution with stunning new design"
                ],
                date: Date()
            ),
            ReleaseNotes(
                version: "1.3",
                buildNumber: 11,
                title: "Enhanced UI & Improved User Experience",
                notes: [
                    "🖼️ Increased thumbnail size on task rows for better visibility",
                    "📱 Improved photo display and interaction in daily checklist",
                    "🎨 Enhanced visual design with larger, more accessible thumbnails",
                    "👆 Better touch targets for photo viewing and interaction",
                    "📋 Improved task row layout and spacing",
                    "🔧 Enhanced photo thumbnail quality and presentation",
                    "🎯 Better user experience for photo-based tasks",
                    "⚡ Optimized thumbnail loading and display performance",
                    "🚀 Ready for TestFlight distribution with improved UI"
                ],
                date: Date()
            ),
            ReleaseNotes(
                version: "1.3",
                buildNumber: 12,
                title: "Optimized Layout for Mobile Devices",
                notes: [
                    "📱 Fixed text wrapping issues on iPhone devices",
                    "🎯 Optimized task row layout for smaller screens",
                    "🖼️ Adjusted thumbnail size for better mobile fit (50x50)",
                    "📝 Limited title and description to 2 lines each",
                    "⚡ Improved responsive design for different screen sizes",
                    "🎨 Better visual balance between text and thumbnails",
                    "📋 Enhanced readability on mobile devices",
                    "🔧 Optimized spacing and alignment for iPhone",
                    "🚀 Ready for TestFlight distribution with mobile-optimized layout"
                ],
                date: Date()
            ),
            ReleaseNotes(
                version: "1.3",
                buildNumber: 13,
                title: "Photo Protection & User Safety",
                notes: [
                    "⚠️ Added photo removal warning when unchecking tasks",
                    "🛡️ Prevents accidental photo deletion with confirmation alert",
                    "📸 Clear warning that photo removal cannot be undone",
                    "🎯 Better user experience for photo-based tasks",
                    "🔒 Protects user's progress photos from accidental loss",
                    "💡 Improved task completion workflow with safety checks",
                    "📱 Enhanced mobile interaction with confirmation dialogs",
                    "🔧 Better error prevention and user guidance",
                    "🚀 Ready for TestFlight distribution with photo protection"
                ],
                date: Date()
            ),
            ReleaseNotes(
                version: "1.3",
                buildNumber: 17,
                title: "Release Notes Always Show on Upgrade",
                notes: [
                    "📝 Release notes now always display on every app upgrade",
                    "🎯 Shows current version's changes instead of combined notes",
                    "🔄 Simplified upgrade experience with consistent release notes",
                    "📱 Better user experience for version updates",
                    "🔧 Fixed release notes logic to be more predictable",
                    "⚡ Improved app startup with proper release note handling",
                    "🎨 Enhanced release notes presentation and timing",
                    "🚀 Ready for TestFlight distribution with improved release notes"
                ],
                date: Date()
            ),
            ReleaseNotes(
                version: "1.3",
                buildNumber: 18,
                title: "Combined Release Notes for Multi-Version Upgrades",
                notes: [
                    "📝 Release notes now show on every upgrade",
                    "🔄 For multi-version upgrades, shows all changes in one scrollable page",
                    "📱 Improved release notes presentation with better organization",
                    "🎯 Enhanced user experience for users upgrading from older versions",
                    "🔧 Better release notes logic for version gap handling",
                    "⚡ Optimized release notes loading and display",
                    "🎨 Improved visual design for combined release notes",
                    "🚀 Ready for TestFlight distribution with enhanced release notes"
                ],
                date: Date()
            ),
            ReleaseNotes(
                version: "1.3",
                buildNumber: 19,
                title: "Version Information in Settings",
                notes: [
                    "📱 Added current version display to Settings page",
                    "ℹ️ Shows version number and build number programmatically",
                    "🎯 Better user awareness of app version",
                    "📋 Clean and organized version information display",
                    "🔧 Improved settings page with version details",
                    "⚡ Version info automatically updates with app builds",
                    "🎨 Consistent design with other settings sections",
                    "🚀 Ready for TestFlight distribution with version display"
                ],
                date: Date()
            ),
            ReleaseNotes(
                version: "1.3",
                buildNumber: 20,
                title: "Simplified Task Row Design",
                notes: [
                    "🎨 Removed photo gallery icons from task rows",
                    "📱 Cleaner and more streamlined task interface",
                    "👁️ Reduced visual clutter in daily checklist",
                    "🎯 Better focus on task completion status",
                    "✨ Simplified user interface for better usability",
                    "📸 Photo functionality still available but less prominent",
                    "🔧 Improved task row layout and spacing",
                    "🚀 Ready for TestFlight distribution with cleaner design"
                ],
                date: Date()
            ),
            ReleaseNotes(
                version: "1.3",
                buildNumber: 21,
                title: "Fixed Photo Functionality for Required Tasks",
                notes: [
                    "🔧 Restored photo functionality for photo-required tasks",
                    "📸 Added minimal camera button for tasks without photos",
                    "✅ Fixed ability to uncheck and recheck photo-required tasks",
                    "🎯 Small green photo indicator shows when task has photo",
                    "📱 Clean interface with functional photo capabilities",
                    "⚡ Improved user experience for photo-based tasks",
                    "🔧 Better photo workflow and task completion logic",
                    "🚀 Ready for TestFlight distribution with working photo features"
                ],
                date: Date()
            ),
            ReleaseNotes(
                version: "1.3",
                buildNumber: 22,
                title: "Fixed App Update Checking on Startup",
                notes: [
                    "🔧 Fixed app update checking to run every time app opens",
                    "📱 Update check now triggers on app startup and splash screen",
                    "✅ Ensures users always see latest version information",
                    "🔄 Added backup update check when main content appears",
                    "⚡ Improved update notification reliability",
                    "🎯 Better user experience with consistent update checking",
                    "🔧 Enhanced app startup workflow and update detection",
                    "🚀 Ready for TestFlight distribution with reliable update checking"
                ],
                date: Date()
            ),
            ReleaseNotes(
                version: "1.3",
                buildNumber: 23,
                title: "Enhanced Settings View with Test-Driven Development",
                notes: [
                    "🧪 Added comprehensive test coverage for Settings view",
                    "📱 Enhanced version information display with accessibility identifiers",
                    "✅ Verified version and build number display functionality",
                    "🔧 Added UI tests to ensure version information is properly shown",
                    "📋 Improved testability with accessibility identifiers for version text",
                    "🎯 Better quality assurance with TDD approach for settings features",
                    "⚡ Enhanced app reliability through comprehensive testing",
                    "🚀 Ready for TestFlight distribution with thoroughly tested settings"
                ],
                date: Date()
            ),
            ReleaseNotes(
                version: "1.3",
                buildNumber: 24,
                title: "Fixed Settings View Layout and Scrolling",
                notes: [
                    "🔧 Fixed Settings view layout to prevent About section from being obscured",
                    "📱 Restructured Settings view to use proper ScrollView instead of Form",
                    "✅ Reset Program button now properly positioned at bottom of scrollable content",
                    "🎯 Improved Settings view scrolling behavior and content visibility",
                    "📋 Enhanced Settings view layout with better spacing and organization",
                    "⚡ Fixed UI layout issues that were affecting iPhone display",
                    "🔧 Better user experience with properly accessible About section",
                    "🚀 Ready for TestFlight distribution with improved Settings view layout"
                ],
                date: Date()
            ),
        ReleaseNotes(
            version: "1.3",
            buildNumber: 7,
            title: "Enhanced User Experience & Performance",
            notes: [
                "🎨 Improved UI/UX design and visual consistency",
                "⚡ Enhanced app performance and responsiveness",
                "🔧 Additional bug fixes and stability improvements",
                "📱 Better mobile experience and accessibility",
                "🔄 Optimized data handling and storage",
                "🎯 Improved user workflow and navigation",
                "📋 Enhanced feature reliability and consistency",
                "🚀 Continued app improvements and refinements"
            ],
            date: Date()
        ),
        ReleaseNotes(
            version: "1.2",
            buildNumber: 6,
            title: "TestFlight Update System & Simulator Compatibility",
            notes: [
                "🔔 Complete TestFlight update notification system",
                "🌐 GitHub-based remote version checking",
                "📱 Direct TestFlight app integration (no URLs needed)",
                "🖥️ Full simulator compatibility and safe testing",
                "⚡ Automatic environment detection (simulator vs device)",
                "🔄 Real-time version comparison with remote server",
                "🎯 Smart update prompts with release notes preview",
                "🔧 Enhanced error handling and graceful fallbacks",
                "📋 Improved update management and user experience",
                "🚀 Ready for production TestFlight distribution"
            ],
            date: Date()
        ),
        ReleaseNotes(
            version: "1.1",
            buildNumber: 5,
            title: "In-App Update Notifications & Enhanced Features",
            notes: [
                "🔔 New in-app update notification system",
                "📱 Automatic update checking and user notifications",
                "🎯 Smart update prompts with release notes preview",
                "⚡ Improved app performance and responsiveness",
                "🔄 Enhanced user experience with update awareness",
                "📋 Better update management and user control",
                "🎨 Improved UI for update notifications",
                "🔧 Additional bug fixes and stability improvements"
            ],
            date: Date()
        ),
        ReleaseNotes(
            version: "1.0",
            buildNumber: 4,
            title: "Thumbnail Path Recovery & Stability",
            notes: [
                "🔧 Fixed thumbnail loading after app upgrades - automatically corrects file paths",
                "⚡ Enhanced image loading with comprehensive fallback search across all directories",
                "🔄 Automatic URL correction when images are found in different locations",
                "📱 Improved thumbnail display reliability across app updates",
                "🐛 Resolved persistent thumbnail issues after app upgrades",
                "🎯 Better handling of file path changes during app updates",
                "📸 Enhanced photo storage and retrieval system",
                "⚡ Improved overall app stability and user experience"
            ],
            date: Date()
        ),
        ReleaseNotes(
            version: "1.0",
            buildNumber: 3,
            title: "Thumbnail Display Fixes",
            notes: [
                "🔧 Fixed thumbnail oscillation when navigating between days",
                "⚡ Improved thumbnail loading performance and reliability",
                "🔄 Enhanced race condition prevention for async image loading",
                "📱 Better visual consistency across calendar navigation",
                "🐛 Resolved thumbnail display issues after app updates",
                "🎯 Improved overall app stability and user experience"
            ],
            date: Date()
        ),
        ReleaseNotes(
            version: "1.0",
            buildNumber: 2,
            title: "Bug Fixes & Improvements",
            notes: [
                "🐛 Fixed thumbnail loading issue after app updates",
                "🔄 Improved auto-advancement logic for day progression",
                "📱 Enhanced missed day detection and navigation",
                "🎯 Fixed 'Continue Anyway' button behavior",
                "📸 Improved camera and photo library integration",
                "⚡ Better app startup performance and reliability"
            ],
            date: Date()
        ),
        ReleaseNotes(
            version: "1.7",
            buildNumber: 1,
            title: "Las Vegas Theme & Enhanced Features",
            notes: [
                "🎰 Added hidden Las Vegas theme with authentic sign colors",
                "🎆 Beautiful fireworks and casino landmarks in Las Vegas theme",
                "🎨 Enhanced theme system with more visual elements",
                "📱 Improved UI responsiveness and performance",
                "🔧 Fixed checkbox functionality and task completion",
                "⚡ Better app stability and user experience",
                "🎯 Enhanced theme selection with hidden easter egg themes",
                "🚀 Ready for TestFlight distribution with new features"
            ],
            date: Date()
        ),
        ReleaseNotes(
            version: "1.7",
            buildNumber: 2,
            title: "UI Improvements & Bug Fixes",
            notes: [
                "🎨 Removed problematic slot machine animations",
                "✅ Fixed checkbox functionality - no more disappearing rows",
                "📱 Improved static icon performance and reliability",
                "🔧 Enhanced app stability and user experience",
                "⚡ Better UI responsiveness and smooth interactions",
                "🎯 Cleaner, more reliable interface design",
                "🐛 Fixed various UI glitches and animation issues",
                "🚀 Ready for TestFlight distribution with improved stability"
            ],
            date: Date()
        ),
        ReleaseNotes(
            version: "1.8",
            buildNumber: 1,
            title: "Enhanced User Experience & Performance",
            notes: [
                "🎯 Fixed 'Continue Anyway' button behavior and date selection",
                "📱 Improved splash screen with enhanced visual effects",
                "⚡ Better app startup performance and reliability",
                "🔧 Enhanced theme system with improved visual elements",
                "🎨 Optimized UI animations and transitions",
                "📸 Improved camera and photo library integration",
                "🐛 Fixed various UI glitches and interaction issues",
                "🚀 Ready for TestFlight distribution with enhanced features"
            ],
            date: Date()
        )
    ]
    
    static func getReleaseNotesForCurrentVersion() -> ReleaseNotes? {
        // Get current app version and build number
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let currentBuild = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "2") ?? 2
        
        // Find the most recent release notes for the current version
        return allReleaseNotes
            .filter { $0.version == currentVersion && $0.buildNumber == currentBuild }
            .first
    }
    
    static func getUnseenReleaseNotes() -> [ReleaseNotes] {
        let lastSeenVersion = UserDefaults.standard.string(forKey: "LastSeenReleaseNotesVersion") ?? "0.0"
        let lastSeenBuild = UserDefaults.standard.integer(forKey: "LastSeenReleaseNotesBuild")
        
        return allReleaseNotes.filter { releaseNotes in
            // Show if this version is newer than what the user has seen
            if releaseNotes.version > lastSeenVersion {
                return true
            } else if releaseNotes.version == lastSeenVersion && releaseNotes.buildNumber > lastSeenBuild {
                return true
            }
            return false
        }
    }
    
    static func markReleaseNotesAsSeen(_ releaseNotes: ReleaseNotes) {
        UserDefaults.standard.set(releaseNotes.version, forKey: "LastSeenReleaseNotesVersion")
        UserDefaults.standard.set(releaseNotes.buildNumber, forKey: "LastSeenReleaseNotesBuild")
    }
    
    // MARK: - Combined Release Notes
    
    /// Returns a combined release note that includes all changes from the user's current version to the latest version
    static func getCombinedReleaseNotes(fromUserVersion userVersion: String, userBuild: Int) -> ReleaseNotes? {
        let userSeenVersion = UserDefaults.standard.string(forKey: "LastSeenReleaseNotesVersion") ?? userVersion
        let userSeenBuild = UserDefaults.standard.integer(forKey: "LastSeenReleaseNotesBuild")
        
        // Get all releases that are newer than what the user has seen
        let newerReleases = allReleaseNotes.filter { release in
            if release.version > userSeenVersion {
                return true
            } else if release.version == userSeenVersion && release.buildNumber > userSeenBuild {
                return true
            }
            return false
        }.sorted { $0.buildNumber < $1.buildNumber }
        
        guard !newerReleases.isEmpty else { return nil }
        
        // Combine all notes from newer releases
        var combinedNotes: [String] = []
        var versionRange = ""
        
        if newerReleases.count == 1 {
            // Single release
            let release = newerReleases[0]
            versionRange = "Version \(release.version) Build \(release.buildNumber)"
            combinedNotes = release.notes
        } else {
            // Multiple releases - create a comprehensive combined note
            let firstRelease = newerReleases.first!
            let lastRelease = newerReleases.last!
            
            if firstRelease.version == lastRelease.version {
                versionRange = "Version \(firstRelease.version) Builds \(firstRelease.buildNumber)-\(lastRelease.buildNumber)"
            } else {
                versionRange = "Versions \(firstRelease.version) Build \(firstRelease.buildNumber) to \(lastRelease.version) Build \(lastRelease.buildNumber)"
            }
            
            // Combine all notes, removing duplicates and organizing by category
            var features: [String] = []
            var bugFixes: [String] = []
            var improvements: [String] = []
            var other: [String] = []
            
            for release in newerReleases {
                for note in release.notes {
                    if note.contains("🐛") || note.contains("🔧") || note.contains("Fixed") {
                        if !bugFixes.contains(note) {
                            bugFixes.append(note)
                        }
                    } else if note.contains("🎨") || note.contains("📱") || note.contains("Enhanced") || note.contains("Improved") {
                        if !improvements.contains(note) {
                            improvements.append(note)
                        }
                    } else if note.contains("🚀") || note.contains("⚡") || note.contains("New") {
                        if !features.contains(note) {
                            features.append(note)
                        }
                    } else {
                        if !other.contains(note) {
                            other.append(note)
                        }
                    }
                }
            }
            
            // Combine in order: features, improvements, bug fixes, other
            combinedNotes.append(contentsOf: features)
            combinedNotes.append(contentsOf: improvements)
            combinedNotes.append(contentsOf: bugFixes)
            combinedNotes.append(contentsOf: other)
        }
        
        let finalRelease = newerReleases.last!
        return ReleaseNotes(
            version: finalRelease.version,
            buildNumber: finalRelease.buildNumber,
            title: "Update to \(versionRange)",
            notes: combinedNotes,
            date: Date()
        )
    }
    
    /// Gets the combined release notes for the current user's upgrade path
    static func getCombinedReleaseNotesForCurrentUser() -> ReleaseNotes? {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let currentBuild = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1") ?? 1
        
        return getCombinedReleaseNotes(fromUserVersion: currentVersion, userBuild: currentBuild)
    }
    
    // MARK: - Build 18 Logic: Combined Release Notes for Multi-Version Upgrades
    
    /// Gets release notes for build 18 logic: always show release notes, but combine if multiple versions
    static func getReleaseNotesForBuild18() -> ReleaseNotes? {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let currentBuild = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1") ?? 1
        
        // Always get release notes for current version
        let currentReleaseNotes = getReleaseNotesForCurrentVersion()
        
        // Check if user is upgrading from more than one version back
        let userSeenVersion = UserDefaults.standard.string(forKey: "LastSeenReleaseNotesVersion") ?? currentVersion
        let userSeenBuild = UserDefaults.standard.integer(forKey: "LastSeenReleaseNotesBuild")
        
        // Get all releases between user's last seen version and current version
        let releasesInRange = allReleaseNotes.filter { release in
            if release.version > userSeenVersion {
                return true
            } else if release.version == userSeenVersion && release.buildNumber > userSeenBuild {
                return true
            }
            return false
        }.sorted { $0.buildNumber < $1.buildNumber }
        
        // If only one version difference, show current version's notes
        if releasesInRange.count <= 1 {
            return currentReleaseNotes
        }
        
        // If multiple versions, create combined release notes
        return createCombinedReleaseNotesForMultipleVersions(releasesInRange)
    }
    
    /// Creates combined release notes for multiple versions in a scrollable format
    private static func createCombinedReleaseNotesForMultipleVersions(_ releases: [ReleaseNotes]) -> ReleaseNotes? {
        guard !releases.isEmpty else { return nil }
        
        let firstRelease = releases.first!
        let lastRelease = releases.last!
        
        // Create version range string
        let versionRange: String
        if firstRelease.version == lastRelease.version {
            versionRange = "Version \(firstRelease.version) Builds \(firstRelease.buildNumber)-\(lastRelease.buildNumber)"
        } else {
            versionRange = "Versions \(firstRelease.version) Build \(firstRelease.buildNumber) to \(lastRelease.version) Build \(lastRelease.buildNumber)"
        }
        
        // Combine all notes from all releases
        var allNotes: [String] = []
        
        for (index, release) in releases.enumerated() {
            // Add version header for each release
            allNotes.append("📱 **\(release.version) Build \(release.buildNumber) - \(release.title)**")
            
            // Add all notes for this release
            allNotes.append(contentsOf: release.notes)
            
            // Add separator between releases (except for the last one)
            if index < releases.count - 1 {
                allNotes.append("")
                allNotes.append("---")
                allNotes.append("")
            }
        }
        
        return ReleaseNotes(
            version: lastRelease.version,
            buildNumber: lastRelease.buildNumber,
            title: "Combined Updates: \(versionRange)",
            notes: allNotes,
            date: Date()
        )
    }
    

} 