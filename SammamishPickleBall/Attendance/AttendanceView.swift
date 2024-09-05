import SwiftUI
import Firebase
import FirebaseDatabase

struct AttendanceButton: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .controlSize(.extraLarge)
                .font(.system(size: 20.0))
                .multilineTextAlignment(.center)
                .padding(.vertical, 14.0)
                .padding(.horizontal, 34.0)
                .background(isSelected ? color : Color(.systemGray5))
                .foregroundColor(isSelected ? .black : .primary)
                .fontWeight(isSelected ? .bold : .regular)
                .cornerRadius(8)
        }
    }
}

struct AttendanceView: View {
    @ObservedObject var viewModel = AttendanceViewModel()
    @State private var attendanceStatus: AttendanceStatus = .notDecided
    @State private var selectedDate = Date()
    @State private var navigateToViewAll = false
    @State private var currentUserId: String = Auth.auth().currentUser?.uid ?? ""  // To track the current user
    @State private var isLoading = true
    @State private var userName: String = "Loading..." // Add this state variable
    @State private var showSignInView = false


    
    
    let userEmail: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {

                Text("Hello, \(userName)")
                    .font(.system(size: 20.0))
                    .foregroundColor(Color.gray)
                    .padding(.bottom, -10.0)
                    .bold()
                
                Text("Pickleball Matchday")
                    .padding(.bottom, 25.0)
                    .font(.system(size: 24.0))
                    .bold()

                // Today's date
                VStack(spacing: 0) {
                    Text(formattedMonth(from: selectedDate))  // Month
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(25)
                        .frame(height: 32.0)
                        .background(Color.green.opacity(0.8))
                        
                    Text(formattedDay(from: selectedDate))  // Day
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .padding()
                        .frame(width: 136.0)
                        .background(Color(.white))
                }
                .background(Color(.systemGray5))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 10)
                
                Text("Today")
                    .foregroundColor(Color.black.opacity(0.8))
                    .padding(.top, -16.0)
                    .font(.system(size: 24.0))
                    .bold()
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.gray.opacity(0.2))
                    .padding()
                    .padding(.bottom, -32.0)

                // Attendees list
                VStack {
                    HStack(spacing: -12.0) {  // Adjust the spacing for slight overlap
                        let numberOfPpl = viewModel.attendances.count
                        Text("\(numberOfPpl) ").bold()+Text("people are going today:")
                            .font(.system(size: 20.0))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, -11.0)
                    .background(Color(.white))
                }
                .padding()
                
                let colors: [Color] = [.red, .green, .black, .yellow, .blue]  // Array of colors to rotate
                
                
                HStack(spacing: 0) {
                    let count = viewModel.attendances.count
                    ForEach(viewModel.attendances.prefix(5).indices, id: \.self) { index in
                        
                        let attendance = viewModel.attendances[index]
                        let userName = viewModel.userNames[attendance.userId] ?? "Loading..."
                        if !attendance.userId.isEmpty {
                            let firstLetter = String(userName.first!).uppercased()
                            let color = colors[index%colors.count]

                            ZStack {
                                Text(firstLetter)
                                    .multilineTextAlignment(.leading)
                                    .bold()
                                    .foregroundColor(.white)  // Text color
                                    .frame(width: 40, height: 40)  // Adjust the size of the circle
                                    .background(Circle().fill(color))  // Circle filled with color
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))  // Optional: add a border
                            }
                            .offset(x: CGFloat(index) * -12)  // Adjust x offset to overlap circles partially
                        }
                    }
                    
                    if count > 5{
                        let remainingCount = count-5
                        Text("+\(remainingCount)")
                            .padding(.leading, -40)
                            .font(.system(size: 24.0))
                            .bold()
                    }
                }
                .padding(.leading, -134)
                .padding(.top, -30)

                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.gray.opacity(0.2))
                    .padding(.bottom, 8.0)

                // Attendance buttons
                Text("Can you attend?")
                    .multilineTextAlignment(.leading)
                    .bold()
                    .font(.system(size: 24.0))
                HStack(spacing: 20) {
                    AttendanceButton(title: "Yes     ", color: .green.opacity(0.8), isSelected: attendanceStatus == .going) {
                        attendanceStatus = .going
                        viewModel.updateAttendance(status: .going, for: selectedDate)
                        viewModel.addCurrentUserToAttendances(userId: currentUserId, for: selectedDate, status: .going)
                    }
                    
                    AttendanceButton(title: "Nope! ", color: .red, isSelected: attendanceStatus == .notDecided) {
                        attendanceStatus = .notDecided
//                        viewModel.updateAttendance(status: .notDecided, for: selectedDate)
//                        viewModel.addCurrentUserToAttendances(userId: currentUserId, for: selectedDate, status: .going)
                    }
                }
                
                if attendanceStatus == .notDecided{
                    Text("YOU'RE MISSING OUT BOOOO!")
                        .bold()
                        .font(.system(size: 20.0))
                }
                
                // Conditional submit button
                if attendanceStatus == .going || attendanceStatus == .maybe {
                    NavigationLink(destination: TimeView()) {
                        Text("Select Times")
                            .font(.system(size: 20.0))
                            .padding(.vertical, 14.0)
                            .padding(.horizontal, 34.0)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 20)
                }
                Spacer()
            }
            .padding()
            
            .onAppear {
                Task{
                    isLoading = true
                    await viewModel.fetchAttendances(for: selectedDate)
                    viewModel.fetchUserName(userID: currentUserId){ name in
                        if let fetchedName = name{
                            userName = fetchedName
                        } else{
                            userName = "Unknown User"
                        }
                    }

                }
                isLoading = false
            }
            .onChange(of: selectedDate) { // Updated to use single-parameter action closure
                Task{
                    isLoading = true  // Start loading when date changes
                    await viewModel.fetchAttendances(for: selectedDate)
                    isLoading = false
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "TimeView" {
                    TimeView()  // Your destination view
                }
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink(destination: SettingsView(showSigninView: $showSignInView)){
                        Image(systemName: "gearshape")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
    
    func formattedMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }

    func formattedDay(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: selectedDate)
    }
    func extractUsername(from email: String) -> String {
        if let range = email.range(of: "@") {
            return String(email[..<range.lowerBound])
        } else {
            return email
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AttendanceView(userEmail: "eyalS@Gmail.com")
    }
}

struct AttendanceViewAlll: View {
    let userEmails: [String]
    let userEmail: String

    var body: some View {
        Text("View All Screen")
    }
}
