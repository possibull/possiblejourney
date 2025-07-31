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
    
    // Session-based dismissal - only dismisses for current app session
    private var dismissedForSession = false
    
                    // Check if this is a TestFlight build
                var isTestFlightBuild: Bool {
                    #if targetEnvironment(simulator)
                    // In simulator, always return false since TestFlight isn't available
                    return false
                    #elseif DEBUG
                    return false
                    #else
                    // For now, we'll assume TestFlight builds have a sandbox receipt
                    // In a real implementation, you might want to use a more sophisticated detection method
                    return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
                    #endif
                }
    
    func checkForUpdates() {
        isChecking = true
        
        // For TestFlight builds, we'll check against remote versions
        // In production, you might want to use a backend API or TestFlight API
        
        // Use the remote API method
        fetchRemoteVersionInfo { remoteVersion, remoteBuild, releaseNotes in
            self.processRemoteVersionCheck(remoteVersion: remoteVersion, build: remoteBuild, releaseNotes: releaseNotes)
            self.isChecking = false
        }
    }
    
    private func checkRemoteUpdateInfo() {
        // TODO: Replace this with actual remote API call
        // For now, we'll simulate a remote check with hardcoded values
        // In production, this should call your backend API or TestFlight API
        
        // Simulate remote version check
        let remoteVersion = "1.2"  // This would come from your backend/API
        let remoteBuild = 6        // This would come from your backend/API
        
        // TODO: Replace the above with actual API call like:
        // fetchRemoteVersionInfo { remoteVersion, remoteBuild in
        //     self.processRemoteVersionCheck(remoteVersion: remoteVersion, build: remoteBuild)
        // }
        
        // Check if remote version is newer than current
        if self.isVersionNewer(remoteVersion, build: remoteBuild) {
            // Find matching release notes for the remote version
            if let remoteNotes = ReleaseNotes.allReleaseNotes.first(where: { 
                $0.version == remoteVersion && $0.buildNumber == remoteBuild 
            }) {
                self.updateInfo = AppUpdateInfo(
                    version: remoteVersion,
                    buildNumber: remoteBuild,
                    releaseNotes: remoteNotes.notes.joined(separator: "\n"),
                    isRequired: false,
                    appStoreURL: "" // Not needed for TestFlight
                )
                self.updateAvailable = true
            } else {
                // If no matching release notes found, create a generic update info
                self.updateInfo = AppUpdateInfo(
                    version: remoteVersion,
                    buildNumber: remoteBuild,
                    releaseNotes: "A new version is available with bug fixes and improvements.",
                    isRequired: false,
                    appStoreURL: "" // Not needed for TestFlight
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
                    // For TestFlight builds, open TestFlight app directly
                    if isTestFlightBuild {
                        #if targetEnvironment(simulator)
                        // In simulator, show an alert or just dismiss
                        print("TestFlight updates not available in simulator")
                        return
                        #else
                        // Use the TestFlight app's specific URL scheme
                        // This should open TestFlight directly without going through App Store
                        if let testFlightURL = URL(string: "testflight://beta") {
                            UIApplication.shared.open(testFlightURL, options: [:]) { success in
                                if !success {
                                    // Fallback to App Store TestFlight page
                                    if let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/testflight/id899247664") {
                                        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                                    }
                                }
                            }
                        }
                        #endif
                    } else {
                        // For App Store builds, open the App Store
                        guard let updateInfo = updateInfo else { return }
                        if let url = URL(string: updateInfo.appStoreURL) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
    
    func dismissUpdateNotification() {
        updateAvailable = false
        // Dismiss only for current session - will show again on app reload
        dismissedForSession = true
        print("DEBUG: Dismissed update notification for current session")
    }
    
    func shouldShowUpdateNotification() -> Bool {
        guard let updateInfo = updateInfo else { return false }
        
        // Only show if not dismissed for current session
        let shouldShow = !dismissedForSession
        
        print("DEBUG: Update notification check - dismissed for session: \(dismissedForSession), should show: \(shouldShow)")
        
        return shouldShow
    }
    
    // MARK: - Remote API Methods (TODO: Implement these)
    
    private func fetchRemoteVersionInfo(completion: @escaping (String, Int, String) -> Void) {
        // GitHub repository: https://github.com/possibull/possiblejourney
        // Raw JSON URL: https://raw.githubusercontent.com/possibull/possiblejourney/main/latest-version.json
        // Update the JSON file in the repository whenever you release new TestFlight builds
        
        guard let url = URL(string: "https://raw.githubusercontent.com/possibull/possiblejourney/main/latest-version.json") else {
            completion("1.0", 1, "A new version is available with bug fixes and improvements.") // Fallback
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let version = json["version"] as? String,
                   let build = json["build"] as? Int {
                    let releaseNotes = json["releaseNotes"] as? String ?? "A new version is available with bug fixes and improvements."
                    completion(version, build, releaseNotes)
                } else {
                    // Fallback to simulated response for testing
                    completion("1.3", 9, "Enhanced User Experience & Performance - Improved UI/UX design and visual consistency - Enhanced app performance and responsiveness - Additional bug fixes and stability improvements - Better mobile experience and accessibility - Optimized data handling and storage - Improved user workflow and navigation - Enhanced feature reliability and consistency - Continued app improvements and refinements")
                }
            }
        }.resume()
    }
    
    private func processRemoteVersionCheck(remoteVersion: String, build: Int, releaseNotes: String) {
        print("DEBUG: Processing remote version check - remote: \(remoteVersion) (\(build)), current: \(currentVersion) (\(currentBuildNumber))")
        
        // Check if remote version is newer than current
        if self.isVersionNewer(remoteVersion, build: build) {
            print("DEBUG: Remote version is newer, showing update notification")
            // Reset session dismissal when a new update is detected
            dismissedForSession = false
            
            // Always create update info with release notes from remote JSON
            self.updateInfo = AppUpdateInfo(
                version: remoteVersion,
                buildNumber: build,
                releaseNotes: releaseNotes,
                isRequired: false,
                appStoreURL: "" // Not needed for TestFlight
            )
            self.updateAvailable = true
        }
    }
} 