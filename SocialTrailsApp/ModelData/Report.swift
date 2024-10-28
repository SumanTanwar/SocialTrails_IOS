//
//  Report.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/28/24.
//

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
