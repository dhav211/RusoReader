import UIKit

class EditBookViewController : UIViewController {
    private let viewModel: EditBookViewModel
    private let titleField: LabeledTextField
    private let authorField: LabeledTextField
    private let cancelButton: UIButton
    private let saveButton: UIButton
    
    var onBookUpdated: () -> Void
    
    init(viewModel: EditBookViewModel) {
        self.viewModel = viewModel
        self.authorField = LabeledTextField(labelText: "Author", defaultFieldText: viewModel.getAuthor())
        self.titleField = LabeledTextField(labelText: "Title", defaultFieldText: viewModel.getTitle())
        self.cancelButton = UIButton()
        self.saveButton = UIButton()
        self.onBookUpdated = {}
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupCancelButton()
        setupSaveButton()
        
        // This gesture recognizer will close the keyboard if open when the user clicks on background of the view
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(onBackgroundTap))
        view.addGestureRecognizer(closeTap)
        
        let contentStack = createContentStackView()
        view.addSubview(contentStack)
        
        // The text fields will call the updateSaveButtonState when edited, this will manage the save buttons enabled state
        authorField.onUpdated = updateSaveButtonState
        titleField.onUpdated = updateSaveButtonState
        
        // Since deleting a book is a highly destructive action we should display a bit of warning just in case the user accidently clicks the delete button
        // This will pop up an alert menu where the user can make the confirmation
        let deleteAction = UIAction(title: "Delete Book") { _ in
            let deleteAlert = UIAlertController(title: "Delete Book", message: "Are you sure you want to delete this book? This action cannot be undone.", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                do {
                    try self.viewModel.deleteBook()
                    self.dismiss(animated: true)
                } catch {
                    print(error)
                    // TODO display another UI Alert if possible saying there was an issue with deleting the book
                }
            })
            self.present(deleteAlert, animated: true)
        }
                
        NSLayoutConstraint.activate([
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
        ])
    }
    
    private func updateSaveButtonState() {
        if viewModel.hasBookBeenEdited(authorFieldText: authorField.getTextFieldValue(), titleFieldText: titleField.getTextFieldValue()) {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    @objc private func onSave() {
        do {
            try viewModel.updateBook(author: authorField.getTextFieldValue(), title: titleField.getTextFieldValue())
            onBookUpdated()
            dismiss(animated: true)
        } catch {
            print(error)
            // TODO Don't just eat this error whe need to display a UI alert letting the user know that book couldn't be updated
        }
    }
    
    @objc private func onCancel() {
        dismiss(animated: true)
    }
    
    @objc private func onBackgroundTap() {
        view.endEditing(true)
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.label, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 24)
        ])
    }
    
    private func setupSaveButton() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.setTitleColor(.systemGray, for: .disabled)
        saveButton.isEnabled = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(onSave), for: .touchUpInside)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            saveButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 24)
        ])
    }
    
    private func createContentStackView() -> UIStackView {
        // Create and place the labeledTextFields in the stack view, these contain a label and a textfield
        let contentStack = UIStackView(arrangedSubviews: [authorField, titleField])
        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        return contentStack
    }
}
