import SwiftUI
import FirebaseDatabase
import Firebase


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
    
    let userEmail: String

    var body: some View {
        VStack(spacing: 30) {
            // Display the user email
            let username = extractUsername(from: userEmail)
            Text("Hello, \(username)")
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
                Text(formattedMonth(from: selectedDate)
                    )  // Month
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(40)
                    .frame(height: 28.0)
                    .background(Color.green.opacity(0.8))
                    

                Text(formattedDay(from: selectedDate))  // Day
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .padding()
                    .frame(width: 113.0)
                    .background(Color(.white))
                
            }
            .background(Color(.systemGray5))
            .cornerRadius(10)
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(Color.gray, lineWidth: 2)
//            )
            .shadow(color: Color.black.opacity(0.2),radius: 10)

            
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
                    Text("\(numberOfPpl) ").bold()+Text("people are going:")
                        .font(.system(size: 20.0))
                    Spacer()
                    Text("view all")
                        .bold()
                        .underline()
                        .padding(.leading, 24.0)
                        .foregroundColor(Color.green)
                        .font(.system(size: 20.0))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, -11.0)
                .background(Color(.white))
            }
            .padding()
            HStack(spacing: 0) {
                ForEach(viewModel.attendances.indices, id: \.self) { index in
                    
                    
                    let attendance = viewModel.attendances[index]
                    let userName = viewModel.userNames[attendance.userId] ?? "Loading..."
                    if !attendance.userId.isEmpty {
                        let firstLetter = String(userName.first!).uppercased()
                        
                        ZStack {
                            Text(firstLetter)
                                .multilineTextAlignment(.leading)
                                .bold()
                                .foregroundColor(.white)  // Text color
                                .frame(width: 40, height: 40)  // Adjust the size of the circle
                                .background(Circle().fill(Color.blue))  // Circle filled with color
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))  // Optional: add a border
                        }
                        .offset(x: CGFloat(index) * -12)  // Adjust x offset to overlap circles partially
                    }
                }
            }
            
            .padding(.leading, -165)
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
                AttendanceButton(title: "Yes", color: .green.opacity(0.8), isSelected: attendanceStatus == .going) {
                    attendanceStatus = .going
                    viewModel.updateAttendance(status: .going, for: selectedDate)
                }
                
                
                AttendanceButton(title: "Maybe", color: .yellow, isSelected: attendanceStatus == .maybe) {
                    attendanceStatus = .maybe
                    viewModel.updateAttendance(status: .maybe, for: selectedDate)
                }
            }
            Spacer()
            
        }
        .padding()
        .onAppear {
            viewModel.fetchAttendances(for: selectedDate)
        }
        .onChange(of: selectedDate) { newDate in
            viewModel.fetchAttendances(for: newDate)
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
