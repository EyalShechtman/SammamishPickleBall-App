import SwiftUI
import Charts
import Firebase
import FirebaseDatabase

struct AttendanceVisualView: View {
    @State private var userIdsForTimeSlots: [[String]] = Array(repeating: [], count: 5)
    @State private var selectedTab: String = "Graph"
    @State private var navigateToAttendance = false
    @State private var VisitedAttendanceView = false
    @ObservedObject var viewModel = AttendanceViewModel()
    @State private var currentUserId: String = Auth.auth().currentUser?.uid ?? ""  // To track the current user
    @State private var userName: String = "Loading..."
    @State private var showSignInView = false
    @State private var currentPeopleCount = 0 // New: Store live number of people at the courts
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect() // Timer to refresh every minute



    let timeSlots = [
        "7:00-9:00",
        "9:00-11:00",
        "13:00-15:00",
        "15:00-17:00",
        "17:00-Dawn"
    ]
    
    let customTimeSlotLabels = [
        "7-9a",
        "9-11a",
        "1-3p",
        "3-5p",
        "5p+"
    ]
    
    var estimatedPeople: Int {
        userIdsForTimeSlots.flatMap { $0 }.count
    }
    
    init(){
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        let attributes: [NSAttributedString.Key:Any]=[
            .foregroundColor: UIColor.white
        ]
        
        let font = UIFont.systemFont(ofSize: 20, weight: .bold) // Adjust the font size and weight here
        
        
        // Attributes for the normal state
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)

        UISegmentedControl.appearance().setTitleTextAttributes(attributes, for: .selected)
    }
    
    var body: some View {
        VStack {
            Text("Sammamish Pickleball")
                .font(.title)
                .bold()
            
            HStack(spacing: 5) {
                // "5 people" label with green color
                Text("\(currentPeopleCount) people")
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0))
                    .bold()
                Image(systemName: "dot.radiowaves.up.forward")
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0))

                // "at the courts" label
                Text("at the courts")
                    .foregroundColor(.black)
                    .padding(.trailing, 0.0)
            }
            .padding(10)
            .background(Color(.white))
            .cornerRadius(5)
            .padding(.top)
            .font(.system(size: 24.0))
            .shadow(radius: 7)
            
            Spacer()
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray).opacity(0.4)
            
            Spacer()
            Text("Attendance Today")
                .font(.title2)
                .bold()
            
            
            Picker(selection: $selectedTab, label: Text("")) {
                Text("Graph").tag("Graph")
                    .padding(.all, 75.0)

                Text("List")
                    .padding(.all, 75.0)
                    .tag("List")
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 165.0, height: 40)
            .padding()

            Spacer()

            if selectedTab == "Graph" {
                ChartView(userIdsForTimeSlots: $userIdsForTimeSlots, timeSlots: timeSlots, customTimeSlotLabels: customTimeSlotLabels)
                    .padding(.horizontal)
            } else {
                AttendeesListView(userIdsForTimeSlots: $userIdsForTimeSlots, timeSlots: timeSlots)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: {
                navigateToAttendance = true
                VisitedAttendanceView = true
            }) {
                Text(VisitedAttendanceView ? "Change My Attendance" : "Mark Attendance")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.vertical, 20.0)
                    .padding(.horizontal, 30.0)
                    .background(Color(red: 0.0, green: 0.5, blue: 0.0))
                    .cornerRadius(35)
            }
            .padding(.bottom)
        }
        .onAppear {
            fetchData()
            updateLivePeopleCount()
        }
        .onReceive(timer) { _ in
            updateLivePeopleCount()
        }
        .navigationDestination(isPresented: $navigateToAttendance) {
            AttendanceView(userEmail: "") // Replace this with the actual destination view
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
    
    
    func updateLivePeopleCount() {
        let currentTime = Date()
        let currentTimeSlotIndex = determineCurrentTimeSlot(for: currentTime)
        
        guard currentTimeSlotIndex >= 0 else {
            currentPeopleCount = 0 // No time slot found, set people count to 0
            return
        }
        
        fetchUsersForTimeSlot(date: currentTime, timeSlot: timeSlots[currentTimeSlotIndex]) { userIds in
            currentPeopleCount = userIds.count // Update the live people count
        }
    }
    
    // New: Function to determine which time slot corresponds to the current time
    func determineCurrentTimeSlot(for date: Date) -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        // Determine the current time slot index based on the hour
        switch hour {
        case 7...8:
            return 0 // 7:00-9:00
        case 9...10:
            return 1 // 9:00-11:00
        case 13...14:
            return 2 // 13:00-15:00
        case 15...16:
            return 3 // 15:00-17:00
        case 17...23:
            return 4 // 17:00-Dawn
        default:
            return -1 // No active time slot
        }
    }

    
    
    
    func fetchData() {
        // Fetch data logic here
        let selectedDate = Date() // Example date, replace with actual selected date
        for index in timeSlots.indices {
            fetchUsersForTimeSlot(date: selectedDate, timeSlot: timeSlots[index]) { userIds in
                userIdsForTimeSlots[index] = userIds
            }
        }
    }
    
    func fetchUsersForTimeSlot(date: Date, timeSlot: String, completion: @escaping ([String]) -> Void) {
        let dateString = formatDate(date)
        
        // Replace with the actual Firebase Database reference
        let dbRef = Database.database().reference()
        
        dbRef.child("Times").child(dateString).child(timeSlot).observeSingleEvent(of: .value) { snapshot in
            var userIds: [String] = []
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if child.value as? Bool == true {
                    userIds.append(child.key)  // The child key is the userId
                }
            }
            completion(userIds)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct ChartView: View {
    @Binding var userIdsForTimeSlots: [[String]]
    let timeSlots: [String]
    let customTimeSlotLabels: [String]
    
    var body: some View {
        
//        Text("People Over Time").bold()
        Chart {
            ForEach(timeSlots.indices, id: \.self) { index in
                BarMark(
                    x: .value("Time Slot",  customTimeSlotLabels[index]),
                    y: .value("Count", userIdsForTimeSlots[index].count)
                )
                .annotation {
                    Text(String(userIdsForTimeSlots[index].count))
                }
                .foregroundStyle(
                    Color(red: 0.0, green: 0.5, blue: 0.0)
                        .opacity(Double(userIdsForTimeSlots[index].count) / Double(userIdsForTimeSlots.max(by: { $0.count < $1.count })?.count ?? 1))
                )
                .cornerRadius(7)
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    Text(value.as(String.self) ?? "")
                        .font(.system(size: 16, weight: .bold)) // Adjust the font size and weight
                        .foregroundColor(.black) // Set the color to black
                }
            }
        }
        .chartXAxisLabel("Time Slot")
        .chartYAxisLabel("Number of People")
        .chartYAxis(.hidden)
        .frame(height: 250)
        .chartPlotStyle{plotContent in
            plotContent
                .background(.white.gradient)
                .border(Color.gray.opacity(0.2))
        }
    }
}

struct AttendeesListView: View {
    @Binding var userIdsForTimeSlots: [[String]]
    let timeSlots: [String]
    @State private var userDictionary: [String: [String: Any]] = [:] // Dictionary to store user data


    
    var body: some View {
        ScrollView {  // Make the view scrollable
            VStack(alignment: .leading, spacing: 10) { // Add spacing between time slots
                ForEach(timeSlots.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(timeSlots[index])
                                .font(.headline)
                                .padding(8)
                                .background(Color(red: 0.0, green: 0.6, blue: 0.0))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            // Placeholder for average level; replace with actual logic
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(userIdsForTimeSlots[index], id: \.self) { userId in
                                HStack {
                                    Text(userDictionary[userId]?["name"] as? String ?? "Unknown") // Display user name
                                        .font(.body)
                                        .foregroundColor(.primary)

                                    Spacer()
                                    
                                    Text("Level \(userDictionary[userId]?["level"] as? Int ?? 0)") // Display user level
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 2) // Add some vertical padding between user rows
                                .onAppear{
                                    fetchAndStoreUserData(userID: userId)
                                }
                            }
                        }
                        .padding(.leading, 10) // Indent user list
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding(.vertical)
        }
    }
    func fetchAndStoreUserData(userID: String) {
        fetchUserNameAndLevel(userID: userID) { name, level in
            userDictionary[userID] = ["name": name, "level": level]
        }
    }
    
    // Function to fetch user's name and level from Firebase
    func fetchUserNameAndLevel(userID: String, completion: @escaping (String, Int) -> Void) {
        let ref = Database.database().reference().child("users").child(userID)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                completion("Unknown", 0) // Return default values if no data found
                return
            }
            
            let name = userData["name"] as? String ?? "Unknown"
            let level = userData["level"] as? Int ?? 0
            
            completion(name, level)
        }
    }
}

#Preview {
    AttendanceVisualView()
}
