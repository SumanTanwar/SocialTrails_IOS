import Foundation

class UserFollow: Codable {
    private(set) var followId: String?
    private(set) var userId: String
    private(set) var followerIds: [String]
    private(set) var followingIds: [String: Bool]
    private(set) var createdOn: String

    init() {
        self.followId = UUID().uuidString
        self.userId = ""
        self.createdOn = Utils.getCurrentDatetime()
        self.followingIds = [:]
        self.followerIds = []
    }

    init(userId: String) {
        self.followId = UUID().uuidString
        self.userId = userId
        self.createdOn = Utils.getCurrentDatetime()
        self.followingIds = [:]
        self.followerIds = []
    }

    func getFollowId() -> String? {
        return followId
    }

    func setFollowId(_ followId: String) {
        self.followId = followId
    }

    func getUserId() -> String {
        return userId
    }

    func setUserId(_ userId: String) {
        self.userId = userId
    }

    func getFollowerIds() -> [String] {
        return followerIds
    }

    func setFollowerIds(_ followerIds: [String]) {
        self.followerIds = followerIds
    }

    func getFollowingIds() -> [String: Bool] {
        return followingIds
    }

    func setFollowingIds(_ followingIds: [String: Bool]) {
        self.followingIds = followingIds
    }

    func addFollowingId(_ followingId: String, isPendingRequest: Bool) {
        followingIds[followingId] = isPendingRequest
    }

    func addFollowerId(_ followerId: String) {
        if !followerIds.contains(followerId) {
            followerIds.append(followerId)
        }
    }

    func getCreatedOn() -> String {
        return createdOn
    }

    func setCreatedOn(_ createdOn: String) {
        self.createdOn = createdOn
    }
}
