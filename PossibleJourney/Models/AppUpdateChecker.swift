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
    
    // Check if this is a TestFlight build
    var isTestFlightBuild: Bool {
        #if DEBUG
        return false
        #else
        // For now, we'll assume TestFlight builds have a sandbox receipt
        // In a real implementation, you might want to use a more sophisticated detection method
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        #endif
    }
    
    func checkForUpdates() {
        isChecking = true
        
        // For TestFlight builds, we'll check against our known versions
        // In production, you might want to use a backend API or TestFlight API
        
        // Simulate checking for updates (replace with actual API call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.checkLocalUpdateInfo()
            self.isChecking = false
        }
    }
    
    private func checkLocalUpdateInfo() {
        // Get the latest version from our release notes
        // In production, you might want to use a backend API or TestFlight API
        
        // Get the latest release notes entry
        guard let latestReleaseNotes = ReleaseNotes.allReleaseNotes.first else {
            return
        }
        
        let latestKnownVersion = latestReleaseNotes.version
        let latestKnownBuild = latestReleaseNotes.buildNumber
        
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
                    appStoreURL: "https://testflight.apple.com/join/your-testflight-link" // Replace with your TestFlight link
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
            // For TestFlight, we need to handle the URL differently
            if isTestFlightBuild {
                // TestFlight links should open in Safari or the TestFlight app
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Regular App Store links
                UIApplication.shared.open(url)
            }
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