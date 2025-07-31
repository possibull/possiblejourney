import SwiftUI

struct UpdateNotificationView: View {
    @ObservedObject var updateChecker: AppUpdateChecker
    @State private var showingReleaseNotes = false
    
    var body: some View {
        if updateChecker.updateAvailable && updateChecker.shouldShowUpdateNotification() {
            VStack(spacing: 0) {
                // Update notification banner
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(updateChecker.isTestFlightBuild ? "New TestFlight Build" : "Update Available")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let updateInfo = updateChecker.updateInfo {
                                Text("Version \(updateInfo.version) (\(updateInfo.buildNumber))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            updateChecker.dismissUpdateNotification()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.title2)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            showingReleaseNotes = true
                        }) {
                            Text("What's New")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            updateChecker.openAppStore()
                        }) {
                            Text(updateChecker.isTestFlightBuild ? "Get Update" : "Update Now")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .sheet(isPresented: $showingReleaseNotes) {
                if let updateInfo = updateChecker.updateInfo {
                    // Use build 18 logic: always show release notes, but combine if multiple versions
                    if let releaseNotes = ReleaseNotes.getReleaseNotesForBuild18() {
                        ReleaseNotesView(
                            releaseNotes: releaseNotes,
                            onDismiss: {
                                showingReleaseNotes = false
                            }
                        )
                    } else {
                        // Fallback to the update info release notes
                        ReleaseNotesView(
                            releaseNotes: ReleaseNotes(
                                version: updateInfo.version,
                                buildNumber: updateInfo.buildNumber,
                                title: "What's New in Version \(updateInfo.version)",
                                notes: updateInfo.releaseNotes.components(separatedBy: "\n"),
                                date: Date()
                            ),
                            onDismiss: {
                                showingReleaseNotes = false
                            }
                        )
                    }
                }
            }
        }
    }
}

// Preview
struct UpdateNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateNotificationView(updateChecker: AppUpdateChecker())
    }
} 