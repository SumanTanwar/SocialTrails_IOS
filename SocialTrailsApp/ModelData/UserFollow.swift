import Foundation

class UserFollow: Codable, Identifiable {
    var followId: String
    var userId: String
    var followerIds: [String]
    var followingIds: [String: Bool]
    var createdOn: String
    
    init() {
           self.followId = UUID().uuidString
           self.userId = ""
           self.createdOn = Utils.getCurrentDatetime()
           self.followerIds = []
           self.followingIds = [:]
       }
    
    init(userId: String) {
        self.followId = UUID().uuidString
        self.userId = userId
        self.createdOn = Utils.getCurrentDatetime()
        self.followerIds = []
        self.followingIds = [:]
    }
    func toDictionary() -> [String: Any] {
        return [
            "followId": followId,
            "userId": userId,
            "followerIds": followerIds,
            "followingIds": followingIds,
            "createdOn": createdOn
        ]
    }

}
