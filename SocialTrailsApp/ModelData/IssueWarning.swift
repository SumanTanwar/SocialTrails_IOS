import Foundation

struct IssueWarning: Identifiable, Codable {
    var id: String { issuewarningId! } // Conforming to Identifiable
    var issuewarningId: String?
    var issuewarnby: String
    var issuewarnto: String
    var issuewarnId: String
    var warningtype: String
    var reason: String
    var createdon: String
    var username: String?
    var userprofilepicture: String?

    // Initializer
    init(issuewarnby: String, issuewarnto: String, issuewarnId: String, warningtype: String, reason: String) {
        self.issuewarnby = issuewarnby
        self.issuewarnto = issuewarnto
        self.issuewarnId = issuewarnId
        self.warningtype = warningtype
        self.reason = reason
        self.createdon = Utils.getCurrentDatetime()
        
    }

    
    // Function to convert to a dictionary (similar to `toMap()` in Java)
    func toDictionary() -> [String: Any?] {
        return [
            "issuewarningId": issuewarningId,
            "issuewarnby": issuewarnby,
            "issuewarnto": issuewarnto,
            "issuewarnId": issuewarnId,
            "warningtype": warningtype,
            "reason": reason,
            "createdon": createdon
        ]
    }
    init(dictionary: [String: Any]) {
        self.issuewarningId = dictionary["issuewarningId"] as? String
        self.issuewarnby = dictionary["issuewarnby"] as? String ?? "Unknown"
        self.issuewarnto = dictionary["issuewarnto"] as? String ?? "Unknown"
        self.issuewarnId = dictionary["issuewarnId"] as? String ?? UUID().uuidString
        self.warningtype = dictionary["warningtype"] as? String ?? "General"
        self.reason = dictionary["reason"] as? String ?? "No reason provided"
        self.createdon = dictionary["createdon"] as? String ?? Utils.getCurrentDatetime() 
    }


}
