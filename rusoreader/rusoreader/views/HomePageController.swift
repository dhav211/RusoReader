//
//  ViewController.swift
//  rusoreader
//
//  Created by Big D on 4/9/26.
//

import UIKit

class HomePageController: UIViewController {
    
    let dbManager: DatabaseManager
    
    init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        let readBookButton = UIButton()
        readBookButton.setTitle("Read Book", for: .normal)
        readBookButton.setTitleColor(.label, for: .normal)
        readBookButton.addTarget(self, action: #selector(pushReaderView), for: .touchUpInside)
        
        stackView.addArrangedSubview(readBookButton)
        
        let addBookButton = AddBookButton()
        addBookButton.delegate = self
        stackView.addArrangedSubview(addBookButton)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func pushReaderView() {
        navigationController?.pushViewController(ReaderView(wordRepo: WordRepository(queue: dbManager.queue)), animated: true)
    }
}
