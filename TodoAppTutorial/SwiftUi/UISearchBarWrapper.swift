//
//  UISearchBarWrapper.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/15.
//

import SwiftUI
import UIKit

struct UISearchBarWrapper: UIViewRepresentable {
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    func makeUIView(context: Context) -> some UIView {
        return UISearchBar()
    }
}
