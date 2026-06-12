import UIKit

protocol EditBookViewDelegate : AnyObject {
    func didDeleteBook(id: Int)
    func didSave(id: Int, author: String?, title: String?)
    func didClose()
}

class EditBookViewController : UIViewController {
    let bookTitle: String
    let bookAuthor: String
    let bookId: Int
    let titleField: LabeledTextField
    let authorField: LabeledTextField
    
    weak var delegate: EditBookViewDelegate?
    
    init(bookTitle: String, bookAuthor: String, bookId: Int) {
        self.bookTitle = bookTitle
        self.bookAuthor = bookAuthor
        self.bookId = bookId
        self.authorField = LabeledTextField(labelText: "Author", defaultFieldText: bookAuthor)
        self.titleField = LabeledTextField(labelText: "Title", defaultFieldText: bookTitle)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        delegate?.didClose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Set the navigation bar buttons with their associated methods
        // Since the navigation controller for this controller in a one time thing we will need to creat a back button, which the cancel fufills
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(onSave))
        
        // This gesture recognizer will close the keyboard if open when the user clicks on background of the view
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(onBackgroundTap))
        view.addGestureRecognizer(closeTap)
        
        // Create and place the labeledTextFields in the stack view, these contain a label and a textfield
        let contentStack = UIStackView(arrangedSubviews: [authorField, titleField])
        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(contentStack)
        
        // Since deleting a book is a highly destructive action we should display a bit of warning just in case the user accidently clicks the delete button
        // This will pop up an alert menu where the user can make the confirmation
        let deleteAction = UIAction(title: "Delete Book") { _ in
            let deleteAlert = UIAlertController(title: "Delete Book", message: "Are you sure you want to delete this book? This action cannot be undone.", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            // The delete button in the alert will actually handle all of the dirty work
            // This calls the methods associated with the delegate, which are handled in the hompage controller
            // THey are done there because the book selector needs to update and the book repository is already there, we just need to send the ID of the book to be deleted
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.delegate?.didDeleteBook(id: self.bookId)
            })
            self.present(deleteAlert, animated: true)
        }
        
        // Link the delete action with a button that is colored red so the user knows its destructive
        let deleteButton = UIButton(primaryAction: deleteAction)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            contentStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func onSave() {
        // If the textFields are the same as the initial value we will create a nil string
        // the didSave implementation will know not to update a value in the book that is nil
        let updatedAuthor : String? = authorField.getTextFieldValue() != bookAuthor ? authorField.getTextFieldValue() : nil
        let updatedTitle : String? = titleField.getTextFieldValue() != bookTitle ? titleField.getTextFieldValue() : nil
        delegate?.didSave(id: bookId, author: updatedAuthor, title: updatedTitle)
    }
    
    @objc private func onCancel() {
        dismiss(animated: true)
    }
    
    @objc private func onBackgroundTap() {
        view.endEditing(true)
    }
}
