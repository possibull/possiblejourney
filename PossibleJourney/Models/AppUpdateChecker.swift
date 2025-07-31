import Foundation
import StoreKit

struct AppUpdateInfo {
    let version: String
    let buildNumber: Int
    let releaseNotes: String
    let isRequired: Bool
    let appStoreURL: String
}

class AppUpdateChecker: ObservableObject {
    @Published var updateAvailable = false
    @Published var updateInfo: AppUpdateInfo?
    @Published var isChecking = false
    
    private let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let currentBuildNumber = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "4") ?? 4
    private let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.mrpossible.PossibleJourney"
    
    func checkForUpdates() {
        isChecking = true
        
        // For now, we'll use a simple approach that checks against our known versions
        // In a production app, you might want to use a backend API or App Store Connect API
        
        // Simulate checking for updates (replace with actual API call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.checkLocalUpdateInfo()
            self.isChecking = false
        }
    }
    
    private func checkLocalUpdateInfo() {
        // This is a simplified version - in production, you'd fetch this from a server
        // For now, we'll check if there's a newer version in our release notes
        
        let latestKnownVersion = "1.1" // This would come from your backend
        let latestKnownBuild = 5 // This would come from your backend
        
        if let latestNotes = ReleaseNotes.allReleaseNotes.first(where: { 
            $0.version == latestKnownVersion && $0.buildNumber == latestKnownBuild 
        }) {
            // Check if this version is newer than current
            if self.isVersionNewer(latestKnownVersion, build: latestKnownBuild) {
                self.updateInfo = AppUpdateInfo(
                    version: latestKnownVersion,
                    buildNumber: latestKnownBuild,
                    releaseNotes: latestNotes.notes.joined(separator: "\n"),
                    isRequired: false,
                    appStoreURL: "https://apps.apple.com/app/id123456789" // Replace with actual App Store URL
                )
                self.updateAvailable = true
            }
        }
    }
    
    private func isVersionNewer(_ version: String, build: Int) -> Bool {
        // Compare version strings
        if version != currentVersion {
            return version > currentVersion
        }
        
        // If versions are the same, compare build numbers
        return build > currentBuildNumber
    }
    
    func openAppStore() {
        guard let updateInfo = updateInfo else { return }
        
        if let url = URL(string: updateInfo.appStoreURL) {
            UIApplication.shared.open(url)
        }
    }
    
    func dismissUpdateNotification() {
        updateAvailable = false
        // Store that user dismissed this version
        UserDefaults.standard.set("\(updateInfo?.version ?? "")_\(updateInfo?.buildNumber ?? 0)", 
                                 forKey: "dismissedUpdateVersion")
    }
    
    func shouldShowUpdateNotification() -> Bool {
        guard let updateInfo = updateInfo else { return false }
        
        let dismissedVersion = UserDefaults.standard.string(forKey: "dismissedUpdateVersion")
        let currentUpdateKey = "\(updateInfo.version)_\(updateInfo.buildNumber)"
        
        return dismissedVersion != currentUpdateKey
    }
} 