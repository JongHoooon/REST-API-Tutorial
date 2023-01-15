//
//  MainVC.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/15.
//

import Foundation
import UIKit
import SwiftUI

class MainVC: UIViewController {
    
    var dummyDataList = ["dfdf", "fdfdf", "dfdfdf", "fdfdfdfd",
                         "dfdf", "fdfdf", "dfdfdf", "fdfdfdfd",
                         "dfdf", "fdfdf", "dfdfdf", "fdfdfdfd"]
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DEBUG -", #fileID, #function, #line)
        self.view.backgroundColor = .systemYellow
        self.myTableView.register(TodoCell.uinib,
                                  forCellReuseIdentifier: TodoCell.reuseIdentifier)
        self.myTableView.dataSource = self
    }
}

extension MainVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return dummyDataList.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier,
                                                 for: indexPath) as? TodoCell
        return cell ?? UITableViewCell()
    }
    
    
}


extension MainVC {
    
    private struct VCRepresentable: UIViewControllerRepresentable {

        let mainVC: MainVC

        func updateUIViewController(_ uiViewController: UIViewControllerType,
                                    context: Context) {
        }

        func makeUIViewController(context: Context) -> some UIViewController {
            return mainVC
        }
    }
    
    func getRepresentable() -> some View {
        VCRepresentable(mainVC: self)
    }
}

// TODO: 코드 자세히 보기
extension UIViewController: StoryBoarded {
    
}

protocol StoryBoarded {
    static func instantiate(_ storyboardName: String?) -> Self
}

extension StoryBoarded {
    static func instantiate(_ storyboardName: String? = nil) -> Self {
        let name = storyboardName ?? String(describing: self)
        
        let storyboard = UIStoryboard(name: name,
                                      bundle: Bundle.main)
        
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! Self
    }
}


protocol Nibbed {
    static var uinib: UINib { get }
}

extension Nibbed {
    static var uinib: UINib {
        return UINib(nibName: String(describing: Self.self),
                     bundle: nil)
    }
}

protocol ReuseIdentifiable {
    static var reuseIdentifier:String { get }
}

extension ReuseIdentifiable {
    static var reuseIdentifier:String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: Nibbed { }
extension UITableViewCell: ReuseIdentifiable { }

