//
//  SignalRService.swift
//  StatusApp
//
//  Created by Matthew Parker on 23/11/2022.
//

import Foundation
import SignalRClient

public class SignalRService {
    var connection: HubConnection
    var accountId = UserDefaults.standard.integer(forKey: "AccountId")
    public init() {
        let path: String = Bundle.main.path(forResource: "Config", ofType: "plist")!
        let config: NSDictionary = NSDictionary(contentsOfFile: path)!
        let connectionString = config.object(forKey: "connectionString") as! String
        let url = URL(string: "\(connectionString)/statushub?AccountId=\(String(accountId))")!

        connection = HubConnectionBuilder(url: url).withLogging(minLogLevel: .error).build()
        connection.on(method: "ReceiveMessage", callback: { (user: String, message: String) in
            self.handleMessage(message, from: user)
        })
        connection.on(method: "ReceiveUpdatedUser", callback: { (friend: User) in
            for i in 0 ... (dataState.friendsList.count - 1) {
                if dataState.friendsList[i].accountId == friend.accountId {
                    dataState.friendsList[i] = friend
                }
            }
        })
        connection.start()
        // Add connectionStatusDelegate
        Thread.sleep(forTimeInterval: 1)
        connection.invoke(method: "SendMessage", "User1", "TestMessage") { error in
            if let error = error {
                print("error: \(error)")
            } else {
                print("Send success")
            }
        }
    }

    private func handleMessage(_ message: String, from user: String) {
        print(user + ": " + message)
    }
}