import UIKit

class EditBookViewController : UIViewController {
    private let viewModel: EditBookViewModel
    private let titleField: LabeledTextField
    private let authorField: LabeledTextField
    private var onClose: () -> Void
    
    init(viewModel: EditBookViewModel) {
        self.viewModel = viewModel
        self.authorField = LabeledTextField(labelText: "Author", defaultFieldText: viewModel.getAuthor())
        self.titleField = LabeledTextField(labelText: "Title", defaultFieldText: viewModel.getTitle())
        self.onClose = {}
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        onClose() // Refreshs the book selector so any possible changes will be reflected
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
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                do {
                    try self.viewModel.deleteBook()
                } catch {
                    print(error)
                    // TODO display another UI Alert if possible saying there was an issue with deleting the book
                }
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
    
    func setOnClose(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    @objc private func onSave() {
        do {
            try viewModel.updateBook(author: authorField.getTextFieldValue(), title: titleField.getTextFieldValue())
        } catch {
            print(error)
            // TODO Don't just eat this error whe need to display a UI alert letting the user know that book couldn't be updated
        }
        dismiss(animated: true)
    }
    
    @objc private func onCancel() {
        dismiss(animated: true)
    }
    
    @objc private func onBackgroundTap() {
        view.endEditing(true)
    }
}
