//
//  main.swift
//  FirstCourseFinalTask
//
//  Copyright © 2017 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker

class User: UserProtocol {
    var id: Identifier
    var username: String
    var fullName: String
    var avatarURL: URL?
    var currentUserFollowsThisUser: Bool
    var currentUserIsFollowedByThisUser: Bool
    var followersArr: [UserProtocol]
    var followedArr: [UserProtocol]
    var followsCount: Int
    var followedByCount: Int
    init(id: Identifier, username: String, fullname: String, avatarURL: URL?) {
        self.avatarURL = avatarURL
        self.id = id
        self.fullName = fullname
        self.username = username
        self.followsCount = 0
        self.followedByCount = 0
        self.currentUserFollowsThisUser = false
        self.currentUserIsFollowedByThisUser = false
        // подписчики пользователя
        followersArr = []
        // подписки пользователя
        followedArr = []
    }
}

class userStorage: UsersStorageProtocol {
    var userArr: [User] = []
    var currUser: User?
    var count: Int {
            return userArr.count
    }
    
    init() {
        currUser = nil
        userArr = []
    }
    
    required init?(users: [FirstCourseFinalTaskChecker.UserInitialData], followers: [(FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>, FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>)], currentUserID: FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>) {
        for element in users {
            userArr.append(User(id: element.id, username: element.username, fullname: element.fullName, avatarURL: element.avatarURL))
        }
        
        for follower in followers  {
            for element in userArr {
                if element.id == follower.0 {
                    for el in userArr {
                        if el.id == follower.1 {
                            element.followedArr.append(el)
                            el.followersArr.append(element)
                        }
                    }
                }
            }
        }
        
        
        for element in userArr {
            element.followedByCount = element.followersArr.count
            element.followsCount = element.followedArr.count
        }
                
        var check = false
        for element in userArr {
            if element.id == currentUserID {
                currUser = element
                for followed in followers {
                    if followed.1 == currUser?.id {
                        for follower in userArr {
                            if follower.id == followed.0 {
                                follower.currentUserIsFollowedByThisUser = true
                            }
                        }
                    }
                }
                
                for el in followers {
                    if el.0 == currUser?.id {
                        for el2 in userArr {
                            if el2.id == el.1 {
                                el2.currentUserFollowsThisUser = true
                            }
                        }
                    }
                }
                check = true
            }
        }
        if check == false {
            return nil
        }
    }
    
    func currentUser() -> UserProtocol {
       return currUser!
    }
    
    func user(with userID: GenericIdentifier<UserProtocol>) -> UserProtocol? {
        for element in userArr {
            if element.id == userID {
                return element
            }
        }
        return nil
    }
    
    func findUsers(by searchString: String) -> [UserProtocol] {
        var arr: [UserProtocol] = []
        for element in userArr {
            if element.username == searchString || element.fullName == searchString {
                arr.append(element)
            }
        }
        return arr
    }
    
    func follow(_ userIDToFollow: GenericIdentifier<UserProtocol>) -> Bool {
        for element in userArr {
            if element.id == userIDToFollow {
                if element.currentUserFollowsThisUser == false {
                    element.currentUserFollowsThisUser = true
                    element.followedByCount += 1
                    
                    for followed in userArr {
                        if followed.id == currUser?.id {
                            followed.followsCount += 1
                            element.followersArr.append(followed)
                            followed.followedArr.append(element)
                        }
                    }
                    
                }
                return true
            }
        }
        return false
    }
    
    func unfollow(_ userIDToUnfollow: GenericIdentifier<UserProtocol>) -> Bool {
        for element in userArr {
            if element.id == userIDToUnfollow {
                if element.currentUserFollowsThisUser == true {
                    element.currentUserFollowsThisUser = false
                    element.followedByCount -= 1
                    for followed in userArr {
                         if followed.id == currUser?.id {
                            followed.followsCount -= 1
                            element.followersArr = element.followersArr.filter { $0.id != followed.id }
                            followed.followedArr = followed.followedArr.filter { $0.id != element.id }
                         }
                     }
                }
                return true
            }
        }
        return false
    }
    
    func usersFollowingUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        for element in userArr {
            if element.id == userID {
                return element.followersArr
            }
        }
        return nil
        
    }
    
    func usersFollowedByUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        for element in userArr {
            if element.id == userID {
                return element.followedArr
            }
        }
        return nil
    }

    func addUser(id: FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>, username: String, fullname: String, avatarURL: URL?, follows: User...) {
        var user = User(id: id, username: username, fullname: fullname, avatarURL: avatarURL)
        for follow in follows {
            user.followedArr.append(follow)
        }
        user.followsCount = user.followedArr.count
        
        for element in userArr {
            for follow in follows {
                if follow.id == element.id{
                    element.followersArr.append(user)
                    element.followedByCount += 1
                }
            }
        }
        
        userArr.append(user)
    }
    
    func checkId(searchId: FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>) -> Bool {
        for element in userArr {
            if element.id == searchId {
                return true
            }
        }
        return false
    }
    
    // добавление подписок
    func addFollowsToUser(searchId: FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>, follows: User...) -> Bool {
        if(!checkId(searchId: searchId)) {
                   return false
               }
        
        for element in userArr {
            if element.id == searchId {
                for follow in follows {
                    element.followedArr.append(follow)
                }
            }
        }
        
        for element in userArr {
            for follow in follows {
                if follow.id == element.id{
                    for el in userArr{
                        if el.id == searchId {
                            element.followersArr.append(el)
                            element.followedByCount += 1
                        }
                    }
                }
            }
        }
        return true
    }
    
    
    // добавление подписчиков
    func addFollowedToUser(searchId: FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>, followed: User...)-> Bool {
        if(!checkId(searchId: searchId)) {
            return false
        }
        
        for element in userArr {
            if element.id == searchId {
                for follow in followed {
                    element.followersArr.append(follow)
                }
            }
        }
        
        for element in userArr {
            for follow in followed {
                if follow.id == element.id{
                    for el in userArr{
                        if el.id == searchId {
                            element.followedArr.append(el)
                            element.followsCount += 1
                        }
                    }
                }
            }
        }
        return true
    }
    
    func clearUser(searchId: FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>) -> Bool {
        for element in userArr {
            if element.id == searchId {
                userArr = userArr.filter { $0.id != searchId }
                return true
            }
        }
        return false
    }
    
    func clearUser(searchString: String) -> Bool {
        for element in userArr {
            if element.username == searchString || element.fullName == searchString {
                userArr = userArr.filter { $0.username != searchString && $0.fullName != searchString }
                return true
            }
        }
        return false
    }
    
    // удаление подписок
    func clearFollowsToUser(searchId: FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>, unfollows: User...) -> Bool {
        if(!checkId(searchId: searchId)) {
                   return false
               }
        
        for element in userArr {
            if element.id == searchId {
                for unfollow in unfollows {
                    element.followedArr = element.followedArr.filter { $0.id != unfollow.id }
                    element.followsCount -= 1
                }
            }
        }
        
        for element in userArr {
            for unfollow in unfollows {
                if unfollow.id == element.id{
                    for el in userArr{
                        if el.id == searchId {
                            element.followersArr = element.followersArr.filter { $0.id != el.id }
                            element.followedByCount -= 1
                        }
                    }
                }
            }
        }
        return true
    }
    
    // удаление подписчиков
    func clearFollowedToUser(searchId: FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>, unfollowed: User...) -> Bool {
        if(!checkId(searchId: searchId)) {
                   return false
               }
        
        for element in userArr {
            if element.id == searchId {
                for unfollow in unfollowed {
                    element.followersArr = element.followedArr.filter { $0.id != unfollow.id }
                    element.followedByCount -= 1
                }
            }
        }
        
        for element in userArr {
            for unfollow in unfollowed {
                if unfollow.id == element.id{
                    for el in userArr{
                        if el.id == searchId {
                            element.followedArr = element.followersArr.filter { $0.id != el.id }
                            element.followsCount -= 1
                        }
                    }
                }
            }
        }
        return true
    }
}

class Post: PostProtocol {
    var id: Identifier
    var author: GenericIdentifier<UserProtocol>
    var description: String
    var imageURL: URL
    var createdTime: Date
    var currentUserLikesThisPost: Bool
    var likedPostArr: [FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>]
    var likedByCount: Int
    init(id: Identifier, author: GenericIdentifier<UserProtocol>, description: String, imageURL: URL, createdTime: Date) {
        self.id = id
        self.author = author
        self.description = description
        self.imageURL = imageURL
        self.createdTime = createdTime
        likedPostArr = []
        self.likedByCount = 0
        self.currentUserLikesThisPost = false
    }
}

class postStorage: PostsStorageProtocol {
    var postArr: [Post] = []
    var currUser: FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>
    required init(posts: [FirstCourseFinalTaskChecker.PostInitialData], likes: [(FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>, FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.PostProtocol>)], currentUserID: FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>) {
        for element in posts {
            postArr.append(Post(id: element.id, author: element.author, description: element.description, imageURL: element.imageURL, createdTime: element.createdTime))
        }
    
        for like in likes {
            for element in postArr {
                if element.id == like.1 {
                    element.likedByCount += 1
                    element.likedPostArr.append(like.0)
                }
            }
        }
        
        currUser = currentUserID
        for like in likes {
            if like.0 == currentUserID{
                for element in postArr{
                    if element.id == like.1 {
                        element.currentUserLikesThisPost = true
                    }
                }
            }
        }
        
    }
    
    var count: Int {
        return postArr.count
    }
    
    func post(with postID: GenericIdentifier<PostProtocol>) -> PostProtocol? {
        for element in postArr {
            if element.id == postID {
                return element
            }
        }
        return nil
    }
    
    func findPosts(by searchString: String) -> [PostProtocol] {
        var arr: [PostProtocol] = []
        for element in postArr {
            if element.description == searchString {
                arr.append(element)
            }
        }
        return arr
    }
    
    func findPosts(by authorID:FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>) -> [FirstCourseFinalTaskChecker.PostProtocol] {
        var arr: [PostProtocol] = []
        for element in postArr {
            if element.author == authorID {
                arr.append(element)
            }
        }
        return arr
    }
    
    func likePost(with postID: GenericIdentifier<PostProtocol>) -> Bool {
        for element in postArr {
            if element.id == postID {
                element.currentUserLikesThisPost = true
                element.likedPostArr.append(currUser)
                element.likedByCount += 1
                return true
            }
        }
        return false
    }
    
    func unlikePost(with postID: GenericIdentifier<PostProtocol>) -> Bool {
       for element in postArr {
            if element.id == postID {
                element.currentUserLikesThisPost = false
                element.likedPostArr = element.likedPostArr.filter { $0 != currUser }
                element.likedByCount -= 1
                return true
            }
        }
        return false
    }
    
    func usersLikedPost(with postID: GenericIdentifier<PostProtocol>) -> [GenericIdentifier<UserProtocol>]? {
        for element in postArr {
            if element.id == postID {
                return element.likedPostArr
            }
        }
        return nil
    }

    func addPost(id: GenericIdentifier<PostProtocol>, author: GenericIdentifier<UserProtocol>, description: String, imageURL: URL, createdTime: Date, likedPosts: FirstCourseFinalTaskChecker.GenericIdentifier<FirstCourseFinalTaskChecker.UserProtocol>...) {
        var post = Post(id: id, author: author, description: description, imageURL: imageURL, createdTime: createdTime)
        for likedPost in likedPosts {
            post.likedPostArr.append(likedPost)
            post.likedByCount += 1
            if likedPost == currUser {
                post.currentUserLikesThisPost = true
            }
        }
        postArr.append(post)
    }
    
    func checkId(searchId: GenericIdentifier<PostProtocol>) -> Bool {
        for element in postArr {
            if element.id == searchId {
                
                return true
            }
        }
        return false
    }
    
    func clearPost(searchId: GenericIdentifier<PostProtocol>) -> Bool {
        if(!checkId(searchId: searchId)) {
            return false
        }
    
        postArr = postArr.filter {  $0.id !=  searchId}
        return true
    }
    
    func clearPost(searchString: String) -> Bool {
        for element in postArr {
            if element.description == searchString {
                postArr = postArr.filter {  $0.description !=  searchString}
                return true
            }
            
        }
            return false
    }
    
    func clearPost(author: GenericIdentifier<UserProtocol>) -> Bool {
        for element in postArr {
            if element.author == author {
                postArr = postArr.filter {  $0.author !=  author }
                return true
            }
            
        }
            return false
    }
}

var checker = Checker(usersStorageClass: userStorage.self, postsStorageClass: postStorage.self)
checker.run()

