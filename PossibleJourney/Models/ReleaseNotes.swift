import Foundation

struct ReleaseNotes {
    let version: String
    let buildNumber: Int
    let title: String
    let notes: [String]
    let date: Date
    
    static let allReleaseNotes: [ReleaseNotes] = [
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