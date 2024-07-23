import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var name = ""
    let uid: String

    init(uid: String) {
        self.uid = uid
    }

    func saveName() async {
        guard !name.isEmpty else {
            print("Name is empty")
            return
        }

        do {
            try await AuthenticationManager.shared.addUserToDatabase(uid: uid, name: name)
            print("Name saved successfully")
        } catch {
            print("Failed to save name: \(error)")
        }
    }
}

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToAttendance = false

    init(uid: String) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(uid: uid))
    }

    var body: some View {
        VStack {
            TextField("Enter your name...", text: $viewModel.name)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            Button {
                Task {
                    await viewModel.saveName()
                    navigateToAttendance = true // Set this to true to navigate
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Onboarding")
        .background( // Add this to handle navigation
            NavigationLink(destination: AttendanceView(userEmail: ""), isActive: $navigateToAttendance) {
                EmptyView()
            }
        )
    }
}

#Preview {
    NavigationStack {
        OnboardingView(uid: "sampleUid")
    }
}
