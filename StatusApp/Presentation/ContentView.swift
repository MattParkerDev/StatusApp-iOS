//
//  ContentView.swift
//  StatusApp
//
//  Created by Matthew Parker on 16/11/2022.
//

import SignalRClient
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataState: DataState
    @Environment(\.scenePhase) var scenePhase
    @State var showProfileView: Bool = false
    @State var showStatusView: Bool = false
    @State var showAddFriendView: Bool = false
    @State var showOnboardingView: Bool = false

    let _authService = AuthService();
    let _userService = UserService();
    let _friendsService = FriendsService();
    var statusRed = Color(UIColor(red: 0.96, green: 0, blue: 0, alpha: 1))
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action: { showProfileView.toggle() }) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color(.init(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)))
                            .frame(width: 35, height: 35)
                            .padding(.leading, 25)
                    }
                    Spacer()
                    Text("Status")
                        .font(.title)
                    Spacer()
                    Button(action: { showStatusView.toggle() }) {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .foregroundColor(dataState.currentUser.online ? .green : statusRed)
                            .shadow(radius: 5)
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .padding(.trailing, 25)
                    }
                }
                Spacer()
                Button("Send Message") {
                    signalR.connection.invoke(method: "BroadcastMessage", dataState.currentUserName, "TestMessage") { error in
                        if let error = error {
                            print("error: \(error)")
                        } else {
                            print("Send success")
                        }
                    }
                    signalR.connection.invoke(method: "GetConnectionUserName", resultType: String.self) { result, error in
                        if let error = error {
                            print("error: \(error)")
                        } else {
                            print(result!)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(5)
                Button("Manage Friends") {
                    showAddFriendView.toggle()
                }
                .buttonStyle(.borderedProminent)
                .padding(5)

                FriendsStatusView()

                Spacer()
            }
            .sheet(isPresented: $showProfileView) {
                ProfileView(showProfileView: $showProfileView, showOnboardingView: $showOnboardingView)
            }
            .sheet(isPresented: $showStatusView) {
                StatusView()
            }
            .sheet(isPresented: $showAddFriendView) {
                AddFriendView()
            }
            .fullScreenCover(isPresented: $showOnboardingView) {
                SignInUpView(showOnboardingView: $showOnboardingView)
            }
            .task {
                if await _authService.CheckAuth() == true {
                    print("CurrentUserName: " + dataState.currentUserName)
                    dataState.currentUser = await _userService.GetUser()
                    dataState.friendsList = await _friendsService.GetFriendsList()
                    dataState.friendships = await _friendsService.GetFriendships()
                    signalR.connection.start()
                } else {
                    showOnboardingView = true
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    print("Changed to Active!")
                    if dataState.signalRState == .didClose || dataState.signalRState == .didFailToOpen {
                        print("Return to Active, reconnecting to SignalR, signalRState:\(dataState.signalRState)")
                        signalR.connection.start()
                    }
                }
                if newPhase == .inactive {
                    print("Changed to Inactive!")
                }
                if newPhase == .background {
                    print("Changed to Background!")
                    if dataState.signalRState == .didOpen {
                        print("App backgrounded, gracefully closing SignalR connection")
                        signalR.connection.stop()
                    }
                }
            }
            .onChange(of: dataState.signalRState) { newState in
                if newState == .didOpen {
                    print("SignalR didOpen")
                    signalR.connection.invoke(method: "BroadcastMessage", dataState.currentUserName, "SignalR Connected") { error in
                        if let error = error {
                            print("error: \(error)")
                        } else {
                            print("Send success")
                        }
                    }
                }
                if newState == .didClose {
                    print("SignalR didClose")
                }
                if newState == .didFailToOpen {
                    print("SignalR didFailToOpen")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataState())
    }
}
