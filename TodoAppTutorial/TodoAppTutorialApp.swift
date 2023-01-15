//
//  TodoAppTutorialApp.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/15.
//

import SwiftUI

@main
struct TodoAppTutorialApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                
                // uikit을 swiftui로 가져온다
                
                TodosView()
                    .tabItem {
                        Image(systemName: "1.square.fill")
                        Text("SwiftUI")
                    }
                MainVC
                    .instantiate()
                    .getRepresentable()
                    .tabItem {
                        Image(systemName: "2.square.fill")
                        Text("UIKit")
                    }
            }
        }
    }
}
