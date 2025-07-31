import Foundation

struct ReleaseNotes {
    let version: String
    let buildNumber: Int
    let title: String
    let notes: [String]
    let date: Date
    
    static let allReleaseNotes: [ReleaseNotes] = [
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
} 