//
//  UserStore.swift
//  TinyduxTests
//
//  Created by burt on 2022/01/15.
//

import Foundation
import Tinydux
import Promises
import Combine

struct User: Equatable, Codable {
    let id: Int
    var name: String
}

struct UserState: State {
    var users: [User] = []
}

class UserStore: Store<UserState> {
    
    init() {
        super.init(state: UserState())
    }
    
    override func worksBeforeCommit() -> [(UserState) -> Void] {
        return [
            { state in print(state.users) }
        ]
    }
    
    override func worksAfterCommit() -> [(UserState) -> Void] {
        return [
            { state in print(state.users) }
        ]
    }
    
    // mutations
    private func SET_USERS(userState: inout UserState, payload: [User]) {
        userState.users = payload
    }
    
    private func SET_USER(userState: inout UserState, payload: User) {
        let index = userState.users.firstIndex { it in
            it.id == payload.id
        }
        
        if let index = index {
            userState.users[index] = payload
        }
    }
    
    private func fetchData(from url: URL) -> Promise<Data?> {
        Promise<Data?>(on: .global()) { resolve, reject in
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    reject(error)                    
                    return
                }
                resolve(data)
            }.resume()
        }
    }
    
    private func fetchData(for request: URLRequest) -> Promise<Data?> {
        Promise<Data?>(on: .global()) { resolve, reject in
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    reject(error)
                    return
                }
                resolve(data)
            }.resume()
        }
    }
    
    // actions
    func loadUsers() -> Promise<UserState> {
        asyncTask { [weak self] in
            guard let self = self else { return }
            do {
                if let data = try awaitPromise(self.fetchData(from: URL(string: "https://jsonplaceholder.typicode.com/users/")!)) {
                    let users = try JSONDecoder().decode([User].self, from: data)
                    self.commit(mutation: self.SET_USERS, payload: users)
                } else {
                    self.commit(mutation: self.SET_USERS, payload: [])
                }
            } catch {
                print(#function, error)
                self.commit(mutation: self.SET_USERS, payload: [])
            }
        }
    }
    
    func update(user: User) throws -> Promise<UserState> {
        asyncTask { [weak self] in
            guard let self = self else { return }
            let params = try JSONEncoder().encode(user)
            var request = URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/users/\(user.id)")!)
            request.httpMethod = "PUT"
            request.httpBody = params
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            if let data = try awaitPromise(self.fetchData(for: request)) {
                let user = try JSONDecoder().decode(User.self, from: data)
                self.commit(mutation: self.SET_USER, payload: user)
            }
        }
    }
}
