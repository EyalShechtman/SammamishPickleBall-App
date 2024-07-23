import SwiftUI
import Firebase
import FirebaseDatabase

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

// MARK: - Attendance View Model
class AttendanceViewModel: ObservableObject {
    @Published var attendances: [Attendance] = []
    @Published var goingAttendances: [String] = []
    @Published var MaybeAttendances: [String] = []
    @Published var userNames: [String: String] = [:]

    
    private var dbRef: DatabaseReference = Database.database().reference()
    
    func fetchAttendances(for date: Date) {
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
        let dateString = formatDate(date) // Ensure this function formats date as expected by the database
        dbRef.child("attendances")
            .queryOrdered(byChild: "date")
            .queryEqual(toValue: dateString)
            .observeSingleEvent(of: .value) { snapshot in
                var attendees: [String] = []
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    if let value = child.value as? [String: Any],
                       let userId = value["userId"] as? String,
                       let status = value["status"] as? String,
                       status == "going" {
                        attendees.append(userId)
                    }
                }
                DispatchQueue.main.async {
                    self.goingAttendances = attendees
                }
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
    
    func updateAttendance(status: AttendanceStatus, for date: Date) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let dateString = formatDate(date)
        let attendance = Attendance(userId: userId, date: dateString, status: status)
        
        dbRef.child("attendances").child(userId + "_" + dateString).setValue(attendance.toDictionary())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
