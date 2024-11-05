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
    var reviewedby: String?
    var actiontakenby: String?

    init() {
        self.reporterId = ""
        self.reportedId = ""
        self.reporttype = ""
        self.reason = ""
        self.status = .pending
        self.createdon = Utils.getCurrentDatetime()
    }

    init(reporterId: String, reportedId: String, reportType: String, reason: String) {
        self.reporterId = reporterId
        self.reportedId = reportedId
        self.reporttype = reportType
        self.reason = reason
        self.status = .pending
        self.createdon = Utils.getCurrentDatetime()
    }

    convenience init(dictionary: [String: Any]) {
        self.init()
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
        self.reviewedby = dictionary["reviewedby"] as? String
        self.actiontakenby = dictionary["actiontakenby"] as? String
    }

    func toDictionary() -> [String: Any?] {
        return [
            "reportId": reportId,
            "reporterId": reporterId,
            "reportedId": reportedId,
            "reportingId": reportingId,
            "reporttype": reporttype,
            "reason": reason,
            "status": status.reportStatus,
            "createdon": createdon,
            "reviewedby": reviewedby,
            "actiontakenby": actiontakenby
        ]
    }
}
