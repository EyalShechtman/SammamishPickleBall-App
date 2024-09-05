import SwiftUI
import Firebase
import FirebaseDatabase

struct TimeView: View {
    @State private var joinedStatuses = Array(repeating: false, count: 5)  // To track whether the user has joined each time slot
    @State private var detailsExpanded = Array(repeating: false, count: 5)  // To show session details
    @State private var userIdsForTimeSlots: [[String]] = Array(repeating: [], count: 5)  // To store user IDs for each time slot
    @State private var userNames: [String: String] = [:]  // To store user names for user IDs
    @State private var navigateToStats = false  // Control navigation to AttendanceVisualView
    @State private var showLeaveConfirmation = false  // To display the confirmation dialog
    @State private var timeSlotIndexToLeave: Int?  // To store the index of the session the user is leaving
    let colors: [Color] = [.red, .green, .blue, .orange, .purple, .pink]  // Colors for initials

    let timeSlots = [
        "7:00-9:00",
        "9:00-11:00",
        "13:00-15:00",
        "15:00-17:00",
        "17:00-Dawn"
    ]

    private var dbRef: DatabaseReference = Database.database().reference()
    @State private var selectedDate = Date()
    @State private var currentUserId: String = Auth.auth().currentUser?.uid ?? ""  // The current user's ID

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Select Pickleballing Sessions")
                    .multilineTextAlignment(.center)
                    .bold()
                    .font(.system(size: 24.0))
                
                ForEach(timeSlots.indices, id: \.self) { index in
                    VStack {
                        HStack {
                            Text(timeSlots[index])
                                .font(.system(size: 16.0))
                            
                            Spacer()
                            
                            HStack(spacing: -10) {
                                let userIds = userIdsForTimeSlots[index]
                                
                                // Display the initials of users who are "going" for this time slot
                                ForEach(userIds.prefix(3), id: \.self) { userId in
                                    if let userName = userNames[userId] {
                                        let initial = String(userName.prefix(1))  // Get the first letter of the user name
                                        CircleView(letter: initial, color: colors.randomElement()!)  // Show user initials in a circle
                                    }
                                }

                                // Display the number of additional users
                                if userIds.count > 3 {
                                    Text("+\(userIds.count - 3)")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 14.0)
                                        .bold()
                                }
                            }
                            
                            // "Join"/"Joined" button
                            Button(action: {
                                if joinedStatuses[index] {
                                    // Store the index of the time slot being left and show confirmation dialog
                                    timeSlotIndexToLeave = index
                                    showLeaveConfirmation = true
                                } else {
                                    joinSession(for: timeSlots[index], at: index)  // User joins the session
                                }
                            }) {
                                Text(joinedStatuses[index] ? "Joined" : "Join")
                                    .font(.system(size: 16.0))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(joinedStatuses[index] ? Color.gray : Color.black)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, -4.0)
                        
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.gray.opacity(0.2))
                            .padding()
                            .padding(-20.0)

                        // Expandable details section
                        DisclosureGroup("Details", isExpanded: $detailsExpanded[index]) {
                            Text("Detailed information about the session at \(timeSlots[index]).")
                                .padding()
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                }
                
                Spacer()
                
//                Button(action: { navigateToStats = true }) {
//                    Text("View Stats")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.green)
//                        .cornerRadius(10)
//                }
            }
            .padding()
            .onAppear {
                fetchJoinedStatuses()  // Fetch joined status
                fetchUserAttendanceData()  // Fetch user attendance data for all time slots
            }
            .navigationDestination(isPresented: $navigateToStats) {
                AttendanceVisualView()  // Navigate to AttendanceVisualView
            }
            .navigationBarItems(trailing: Button("Done") {
                navigateToStats = true  // Navigate to the stats view when "Done" is pressed
            })
            // Confirmation dialog for leaving a session
            .alert(isPresented: $showLeaveConfirmation) {
                Alert(
                    title: Text("Leave Session"),
                    message: Text("Are you sure you want to leave this session?"),
                    primaryButton: .destructive(Text("Leave")) {
                        if let index = timeSlotIndexToLeave {
                            leaveSession(for: timeSlots[index], at: index)  // Leave the session
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    // Fetch the current user's "joined" status for each time slot from Firebase
    func fetchJoinedStatuses() {
        let dateString = formatDate(selectedDate)
        
        for (index, timeSlot) in timeSlots.enumerated() {
            dbRef.child("Times").child(dateString).child(timeSlot).observeSingleEvent(of: .value) { snapshot in
                if snapshot.hasChild(currentUserId) {
                    joinedStatuses[index] = true  // User has joined this session
                } else {
                    joinedStatuses[index] = false  // User has not joined this session
                }
            }
        }
    }

    // Fetch user attendance data for all time slots (user IDs and names)
    func fetchUserAttendanceData() {
        let dateString = formatDate(selectedDate)
        
        for (index, timeSlot) in timeSlots.enumerated() {
            dbRef.child("Times").child(dateString).child(timeSlot).observeSingleEvent(of: .value) { snapshot in
                var userIds: [String] = []
                
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    if let isGoing = child.value as? Bool, isGoing {
                        let userId = child.key
                        userIds.append(userId)
                        
                        // Fetch the user's name if it's not already in the userNames dictionary
                        if userNames[userId] == nil {
                            fetchUserName(for: userId)
                        }
                    }
                }
                
                userIdsForTimeSlots[index] = userIds  // Update the user IDs for this time slot
            }
        }
    }

    // Fetch a user's name from Firebase and store it in the userNames dictionary
    func fetchUserName(for userId: String) {
        dbRef.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            if let userData = snapshot.value as? [String: Any], let userName = userData["name"] as? String {
                DispatchQueue.main.async {
                    userNames[userId] = userName  // Store the user's name in the dictionary
                }
            }
        }
    }
    
    // User joins a session and updates the UI immediately
    func joinSession(for timeSlot: String, at index: Int) {
        let dateString = formatDate(selectedDate)
        dbRef.child("Times").child(dateString).child(timeSlot).child(currentUserId).setValue(true)
        
        // Immediately update the local state to show the user's bubble live
        joinedStatuses[index] = true  // Update the UI to show "Joined"
        if !userIdsForTimeSlots[index].contains(currentUserId) {
            userIdsForTimeSlots[index].append(currentUserId)  // Add the user to the time slot attendees
        }

        // Fetch the current user's name (if not already in the userNames dictionary) and update initials
        if userNames[currentUserId] == nil {
            fetchUserName(for: currentUserId)
        }
    }

    // User leaves a session
    func leaveSession(for timeSlot: String, at index: Int) {
        let dateString = formatDate(selectedDate)
        dbRef.child("Times").child(dateString).child(timeSlot).child(currentUserId).removeValue()
        joinedStatuses[index] = false  // Update the UI
        
        // Remove the user from the userIdsForTimeSlots array for the respective time slot
        if let userIndex = userIdsForTimeSlots[index].firstIndex(of: currentUserId) {
            userIdsForTimeSlots[index].remove(at: userIndex)  // Remove the user from the session's attendees
        }
    }

    // Format the date as "yyyy-MM-dd"
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct CircleView: View {
    let letter: String
    let color: Color
    
    var body: some View {
        ZStack {
            Text(letter)
                .multilineTextAlignment(.center)
                .font(.system(size: 14.0))
                .bold()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Circle().fill(color))
                .overlay(Circle().stroke(Color.white, lineWidth: 1))
        }
    }
}

struct TimeView_Previews: PreviewProvider {
    static var previews: some View {
        TimeView()
    }
}
