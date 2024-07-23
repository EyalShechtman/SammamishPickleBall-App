import SwiftUI

struct AttendanceViewAll: View {
    @ObservedObject var viewModel = AttendanceViewModel()
    @State private var selectedDate = Date()

    let userEmails: [String]
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
            .shadow(color: Color.black.opacity(0.2),radius: 10)

            Text("Today")
                .foregroundColor(Color.black.opacity(0.8))
                .padding(.top, -16.0)
                .font(.system(size: 24.0))
                .bold()
            
            
            Text("Attendees: (\(viewModel.MaybeAttendances.count + viewModel.goingAttendances.count))")
                .multilineTextAlignment(.leading)
                .bold()
                .font(.system(size: 24.0))
                .padding(.trailing, 225.0)
                .padding(.bottom, -20.0)

            
//            Text(viewModel.goingAttendances.description)
//            Text(viewModel.MaybeAttendances.description)
            List {
                Section(header: Text("Going (\(viewModel.goingAttendances.count))").bold().font(.system(size: 16.0))) {
                    ForEach(viewModel.goingAttendances, id: \.self) { email in
                        HStack {
                            if !email.isEmpty {
                                let index = email.index(email.startIndex, offsetBy: 0)
                                let firstLetter = String(email[index]).uppercased()
                                Text(firstLetter)
                                    .multilineTextAlignment(.leading)
                                    .bold()
                                    .foregroundColor(.white)  // Text color
                                    .frame(width: 30, height: 30)  // Adjust the size of the circle
                                    .background(Circle().fill(Color.blue))  // Circle filled with color
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))  // Optional: add a border
                                    .padding(.leading, 12)
                            }
                            Text(extractUsername(from: email))
                            Spacer()
                        }
                    }
                }
                Section(header: Text("Maybe (\(viewModel.MaybeAttendances.count))").bold().font(.system(size: 16.0))) {
                    ForEach(viewModel.MaybeAttendances, id: \.self) { email in
                        HStack {
                            if !email.isEmpty {
                                let index = email.index(email.startIndex, offsetBy: 0)
                                let firstLetter = String(email[index]).uppercased()
                                Text(firstLetter)
                                    .multilineTextAlignment(.leading)
                                    .bold()
                                    .foregroundColor(.white)  // Text color
                                    .frame(width: 30, height: 30)  // Adjust the size of the circle
                                    .background(Circle().fill(Color.blue))  // Circle filled with color
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))  // Optional: add a border
                                    .padding(.leading, 12)
                            }
                            Text(extractUsername(from: email))
                            Spacer()
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchGoingAttendees(for: selectedDate)
        }
        .onChange(of: selectedDate) { newDate in
            viewModel.fetchGoingAttendees(for: newDate)
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
    
    func extractUsername(from email: String) -> String {
        if let range = email.range(of: "@") {
            return String(email[..<range.lowerBound])
        } else {
            return email
        }
    }
}

struct AttendanceViewAll_Previews: PreviewProvider {
    static var previews: some View {
        AttendanceViewAll(userEmails: ["example@gmail.com", "example1@gmail.com", "example2@gmail.com", "example3@gmail.com"], userEmail: "example@gmail.com")
    }
}
