//
//  TodosView.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/15.
//

import Foundation
import SwiftUI

struct TodosView: View {
    
    @StateObject var todosVM: TodosVM = TodosVM()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            getHeader()
            
            UISearchBarWrapper()
            
            Spacer()
            
            List {
                TodoRow()
                TodoRow()
                TodoRow()
                TodoRow()
            }
            .listStyle(.plain)
        }
    }
    
    private func getHeader() -> some View {
        Group {
            topHeader
            
            secondHeader
        }
        .padding(.horizontal, 10)
    }
    
    /// top 헤더
    private var topHeader: some View {
        
        Group {
            Text("TodosView / page: 0")
            Text("선택된 할일: []")
            
            HStack {
                Button(action: { }, label: {
                    Text("클로저")
                })
                    .buttonStyle(MyDefaultButtonStyle())
                
                Button(action: { }, label: {
                    Text("Rx")
                })
                    .buttonStyle(MyDefaultButtonStyle())
                
                Button(action: { }, label: {
                    Text("콤바인")
                })
                    .buttonStyle(MyDefaultButtonStyle())
                
                Button(action: { }, label: {
                    Text("Async")
                })
                .buttonStyle(MyDefaultButtonStyle())
            }
        }
    }
    
    /// second 헤더
    private var secondHeader: some View {
        Group {
            Text("Async 변환 액션들")
            
            HStack {
                Button(action: { }, label: { Text("클로저 👉 Async") })
                    .buttonStyle(MyDefaultButtonStyle())
                
                Button(action: { }, label: { Text("Rx 👉 Async") })
                    .buttonStyle(MyDefaultButtonStyle())
                Button(action: { }, label: { Text("콤바인 👉 Async") })
                    .buttonStyle(MyDefaultButtonStyle())
            }
            
            HStack {
                Button(action: { }, label: { Text("초기화") })
                    .buttonStyle(MyDefaultButtonStyle(bgColor: .purple))
                
                Button(action: { }, label: { Text("선택된 할일들 삭제") })
                    .buttonStyle(MyDefaultButtonStyle(bgColor: .black))
                
                Button(action: { }, label: { Text("할 일 추가") })
                    .buttonStyle(MyDefaultButtonStyle(bgColor: .gray))
            }
        }
    }
}

struct TodosView_Previews: PreviewProvider {
    
    static var previews: some View {
        TodosView()
    }
}
