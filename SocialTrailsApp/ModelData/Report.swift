import Foundation

class Report {
    var reportId: String?
    var reporterId: String
    var reportedId: String
    var reportingId: String?
    var reporttype: String
    var reason: String
    var status: ReportStatus
    var createdon: String
    var username: String?
    var userprofilepicture: String?
    // Default initializer
    init() {
        self.reporterId = ""
        self.reportedId = ""
        self.reporttype = ""
        self.reason = ""
        self.status = .pending
        self.createdon = Utils.getCurrentDatetime()
    }

    // Initializer for creating a report with specific values
    init(reporterId: String, reportedId: String, reportType: String, reason: String) {
        self.reporterId = reporterId
        self.reportedId = reportedId
        self.reporttype = reportType
        self.reason = reason
        self.status = .pending
        self.createdon = Utils.getCurrentDatetime()
    }

    // Initializer to create a Report from a dictionary
    convenience init(dictionary: [String: Any]) {
        self.init() // Call the default initializer
        self.reportId = dictionary["reportId"] as? String
        self.reporterId = dictionary["reporterId"] as? String ?? ""
        self.reportedId = dictionary["reportedId"] as? String ?? ""
        self.reportingId = dictionary["reportingId"] as? String
        self.reporttype = dictionary["reporttype"] as? String ?? ""
        self.reason = dictionary["reason"] as? String ?? ""
        let statusString = dictionary["status"] as? String ?? "pending"
        self.status = ReportStatus(rawValue: statusString) ?? .pending
        self.createdon = dictionary["createdon"] as? String ?? Utils.getCurrentDatetime()
        self.username = dictionary["username"] as? String ?? ""
        self.userprofilepicture = dictionary["userprofilepicture"] as? String ?? ""
    }

    // Convert Report object to dictionary
    func toDictionary() -> [String: Any?] {
        return [
            "reportId": reportId,
            "reporterId": reporterId,
            "reportedId": reportedId,
            "reportingId": reportingId,
            "reporttype": reporttype,
            "reason": reason,
            "status": status.reportStatus,
            "createdon": createdon
        ]
    }

   
}
