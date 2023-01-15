//
//  TodoRow.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/15.
//

import SwiftUI

struct TodoRow: View {
    
    @State var isSelected: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("id: 123 / 완료여부: 미완료")
                Text("오늘도 빡코딩")
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .trailing) {
                actionButtons
                Toggle(isOn: $isSelected, label: {
                    EmptyView()
                })
                .background(Color.gray)
                .frame(width: 80)
            }
            
            
        }
        .frame(maxWidth: .infinity)
//        .background(Color.yellow)
    }
    
    private var actionButtons: some View {
        HStack {
            Button(action: {}) {
                Text("수정")
            }
            .buttonStyle(MyDefaultButtonStyle())
            .frame(width: 80)
            
            Button(action: {}) {
                Text("삭제")
            }
            .buttonStyle(MyDefaultButtonStyle(bgColor: .purple))
            .frame(width: 80)
        }
    }
    
    
}

struct TodoRow_Previews: PreviewProvider {
    static var previews: some View {
        TodoRow()
    }
}
