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
            buildNumber: 8,
            title: "Session-Based Update Notifications & Direct TestFlight Integration",
            notes: [
                "🔔 Fixed update notification dismissal to be session-based only",
                "🔄 Update notifications now reappear on app reload and program reset",
                "📱 Direct TestFlight app integration (bypasses App Store)",
                "🎯 Persistent update reminders until user actually updates",
                "⚡ Improved TestFlight URL scheme handling",
                "🖥️ Enhanced simulator compatibility for update system",
                "🔧 Better update notification user experience",
                "📋 Improved update management and user control",
                "🚀 Ready for production TestFlight distribution with persistent reminders"
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
} 