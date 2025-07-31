import SwiftUI

struct ReleaseNotesView: View {
    let releaseNotes: ReleaseNotes
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's New")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Version \(releaseNotes.version) (\(releaseNotes.buildNumber))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(releaseNotes.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 10)
                    
                    // Release notes
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(releaseNotes.notes, id: \.self) { note in
                            HStack(alignment: .top, spacing: 12) {
                                // Bullet point
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 8)
                                
                                Text(note)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Footer
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Thank you for using Possible Journey!")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("We're constantly working to improve your experience.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Continue") {
                        // Mark as seen and dismiss
                        ReleaseNotes.markReleaseNotesAsSeen(releaseNotes)
                        onDismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ReleaseNotesModalView: View {
    @Binding var isPresented: Bool
    let releaseNotes: ReleaseNotes
    
    var body: some View {
        ReleaseNotesView(releaseNotes: releaseNotes) {
            isPresented = false
        }
    }
}

#Preview {
    let sampleReleaseNotes = ReleaseNotes(
        version: "1.0",
        buildNumber: 2,
        title: "Bug Fixes & Improvements",
        notes: [
            "🐛 Fixed thumbnail loading issue after app updates",
            "🔄 Improved auto-advancement logic for day progression",
            "📱 Enhanced missed day detection and navigation"
        ],
        date: Date()
    )
    
    return ReleaseNotesView(releaseNotes: sampleReleaseNotes) {
        print("Dismissed")
    }
} 