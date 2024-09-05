import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var name = ""
    @Published var level = 1
    
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
            try await AuthenticationManager.shared.addUserToDatabase(uid: uid, name: name, level: level)
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
    @State private var selectedLevel = 1

    init(uid: String) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(uid: uid))
    }

    var body: some View {
        VStack {
            Text("Enter Full Name")
                .font(.system(size: 20.0))
                .bold()
            TextField("Enter your full name...", text: $viewModel.name)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()
            Text("Select your level")
                .bold()
                .font(.system(size: 20.0))

            Picker("Level", selection: $selectedLevel) {
                ForEach(1..<6) { level in
                    Text("\(level)").tag(level)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            HStack {
                Text("Beginner") // Text under number 1
                    .font(.system(size: 14.0))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, -15.0)

                Spacer()

                Text("Best at ESP") // Text under number 5
                    .font(.system(size: 14.0))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, -15.0)
            }
            .padding(.horizontal)



            Button {
                Task {
                    viewModel.level = selectedLevel
                    await viewModel.saveName()
                    navigateToAttendance = true
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor(_colorLiteralRed: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)))
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $navigateToAttendance) {
            AttendanceVisualView()
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView(uid: "sampleUid")
    }
}
