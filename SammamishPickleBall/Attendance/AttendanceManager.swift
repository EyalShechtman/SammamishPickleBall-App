import SwiftUI
import Firebase
import FirebaseDatabase
import UIKit

enum AttendanceStatus: String, Codable {
    case going, maybe, notDecided
}

struct Attendance: Identifiable {
    var id: String?
    let userId: String
    let date: String
    let status: AttendanceStatus
    
    init(id: String? = nil, userId: String, date: String, status: AttendanceStatus) {
        self.id = id
        self.userId = userId
        self.date = date
        self.status = status
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
            "date": date,
            "status": status.rawValue
        ]
    }
}


struct TimeSlot{
    let date: String
    let timeOption: String
    let userId: String
    
    func toDictionary() -> [String: Any]{
        return[
            "date": date,
             "userId": userId
        ]
    }
}


class AttendanceViewModel: ObservableObject {
    @Published var attendances: [Attendance] = []
    @Published var goingAttendances: [Attendance] = []
    @Published var MaybeAttendances: [String] = []
    @Published var userNames: [String: String] = [:]

    
    private var dbRef: DatabaseReference = Database.database().reference()
    
    func fetchAttendances(for date: Date) async{
        let dateString = formatDate(date)
        dbRef.child("attendances").queryOrdered(byChild: "date").queryEqual(toValue: dateString).observe(.value) { snapshot in
            var newAttendances: [Attendance] = []
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let value = child.value as? [String: Any],
                   let userId = value["userId"] as? String,
                   let date = value["date"] as? String,
                   let statusRaw = value["status"] as? String,
                   let status = AttendanceStatus(rawValue: statusRaw) {
                    let attendance = Attendance(id: child.key, userId: userId, date: date, status: status)
                    newAttendances.append(attendance)
                }
            }
            DispatchQueue.main.async {
                self.attendances = newAttendances
                for attendance in newAttendances {
                    if self.userNames[attendance.userId] == nil {
                        self.fetchUserName(userID: attendance.userId) { _ in }
                    }
                }
            }
        }
    }
    
    
    
    
    func fetchUserName(userID: String, completion: @escaping (String?) -> Void) {
        dbRef.child("users").child(userID).observeSingleEvent(of: .value, with: { snapshot in
            if let userInfo = snapshot.value as? [String: Any],
               let name = userInfo["name"] as? String {
                DispatchQueue.main.async {
                    self.userNames[userID] = name
                    completion(name)
                }
            } else {
                completion(nil)
            }
        }) { error in
            print("Error: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    
    
    func fetchGoingAttendees(for date: Date) {
        let dateString = formatDate(date)
        dbRef.child("attendances")
            .queryOrdered(byChild: "date")
            .queryEqual(toValue: dateString)
            .observeSingleEvent(of: .value) { snapshot in
                var attendees: [Attendance] = []
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    if let value = child.value as? [String: Any],
                       let userId = value["userId"] as? String,
                       let status = value["status"] as? String,
                       let timeOption = value["timeOption"] as? String,
                       status == "going" {
                        let attendance = Attendance(id: child.key, userId: userId, date: dateString, status: .going)
                        attendees.append(attendance)
                    }
                }
                DispatchQueue.main.async {
                    self.goingAttendances = attendees  // Assign the Attendance array
                }
            }
    }

    func addCurrentUserToAttendances(userId: String, for date: Date, status: AttendanceStatus) {
        let dateString = formatDate(date)
        
        // Check if user is already present in the attendances list
        if !attendances.contains(where: { $0.userId == userId }) {
            let newAttendance = Attendance(userId: userId, date: dateString, status: status)
            attendances.append(newAttendance)
            fetchUserName(userID: userId) { _ in }  // Fetch user name and update UI
        }
    }
    
    //MaybeAttending Function - NOT DONE
    func fetchMaybeAttendees(for date: Date) {
        let dateString = formatDate(date)
        dbRef.child("attendances")
            .queryOrdered(byChild: "date")
            .queryEqual(toValue: dateString)
            .observeSingleEvent(of: .value) { snapshot in
                var Maybeattendees: [String] = []
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    if let value = child.value as? [String: Any],
                       let userId = value["userId"] as? String,
                       let status = value["status"] as? String,
                       status == "maybe" {
                        Maybeattendees.append(userId)
                    }
                }
                DispatchQueue.main.async {
                    self.MaybeAttendances = Maybeattendees
                }
            }
    }
    
    
    func submitAttendance(for date: Date, status: AttendanceStatus, timeOption: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let dateString = formatDate(date)
        let attendance = Attendance(userId: userId, date: dateString, status: status)
        
        // Update Attendances node
        dbRef.child("attendances").child(userId + "_" + dateString).setValue(attendance.toDictionary())
        
        // Update Times node
        updateTimesNode(for: dateString, timeOption: timeOption, userId: userId)
    }

    
    private func updateTimesNode(for date: String, timeOption: String, userId: String) {
        let timeSlotRef = dbRef.child("Times").child(date).child(timeOption)
        
        // Add the user's ID to the appropriate time option
        timeSlotRef.child(userId).setValue(true) // true is a placeholder value
        }
    
    
    func updateAttendance(status: AttendanceStatus, for date: Date) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let dateString = formatDate(date)
        let attendance = Attendance(userId: userId, date: dateString, status: status)
        
        dbRef.child("attendances").child(userId + "_" + dateString).setValue(attendance.toDictionary())
    }
    
    func submitAttendance(for date: Date, status: AttendanceStatus) {
        updateAttendance(status: status, for: date)
    }
    
    func getUsersForTimeSlot(date: Date, timeSlot: String, completion: @escaping ([String]) -> Void) {
        let dateString = formatDate(date)
        
        // Query the Times node for the specific date and time slot
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

    func removeAttendance(for date: Date, timeOption: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let dateString = formatDate(date)
        
        // Remove attendance from both "Attendances" and "Times" nodes
        dbRef.child("attendances").child(userId + "_" + dateString).removeValue()
        dbRef.child("Times").child(dateString).child(timeOption).child(userId).removeValue()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
