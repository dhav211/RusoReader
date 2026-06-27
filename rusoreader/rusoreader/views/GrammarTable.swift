import UIKit

class GrammarTable: UIStackView {
    private let viewModel: WordDetailsViewModel
    private let tableType: GrammarFormTableData.TableType
    private let grammarFormTableData: GrammarFormTableData
    
    init(tableType: GrammarFormTableData.TableType, viewModel: WordDetailsViewModel) {
        self.viewModel = viewModel
        self.tableType = tableType
        self.grammarFormTableData = viewModel.createGrammarFormTableData(grammarTableType: tableType)
        
        super.init(frame: .zero)
        
        axis = .vertical
        distribution = .fill
        spacing = 4

        // We are holding all the labels so we can compare them the the longestRowInColumns array to see which label is the biggest, then we use that as a width anchor for getting centering
        var cells = [[UILabel]]()

        // Create the the row stacks and text labels.
        // The labels will added to the stacks in the order of the cell texts 2d array
        // we are also adding the labels to their own 2d array which will be used to set the anchors
        for row in 0..<grammarFormTableData.forms.count {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 16
            addArrangedSubview(rowStack)
            cells.append([])
            
            createRows(rows: grammarFormTableData.forms[row]).forEach { cellRow in
                rowStack.addArrangedSubview(cellRow)
                
                // We grab the first element of the stack and add it to the cells array for anchoring
                if let firstVariation = cellRow.arrangedSubviews.first as? UILabel {
                    cells[row].append(firstVariation)
                }
            }
            
            // puts a simple separator between each rows, the first separator will be darker
            if row < grammarFormTableData.forms.count - 1 { // ensure we don't a separator at the bottom of the table
                let separator = UIView()
                separator.backgroundColor = row > 0 ? .separator : .label
                separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                addArrangedSubview(separator)
            }
        }
        
        setWidthAnchors(cells: cells)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Compares finds which cell's text has the most characters and sets the width anchor to that, this will help all the rows line up in columns
    /// - Parameter cells: Each cell's first UILabel in an 2D array
    private func setWidthAnchors(cells: [[UILabel]]) {
        // We want to find out which string is the longest in each column, this will determine which label to anchor off of
        let longestRowInColumns = viewModel.getLongestRows(grammarFormTableData: grammarFormTableData)
        
        // Here we set the anchors, we will check the row/column to see if it lines up with the index of the longestRowInColumns array. If it doesn't then we know we need to set the anchor
        for row in 0..<cells.count {
            for column in 0..<cells[row].count {
                if longestRowInColumns[row] != column {
                    cells[row][column].widthAnchor.constraint(equalTo: cells[row][longestRowInColumns[row]].widthAnchor).isActive = true
                }
            }
        }
    }
    
    /// Creates the UILabels inside of stack views which will ultimately make up the rows the user sees in the grammar table
    /// - Parameter rows: The row of word forms
    /// - Returns: The row of word forms as UIStackView
    private func createRows(rows: [GrammarFormTableData.Cell]) -> [UIStackView] {
        return rows.map { row in
            let varationStack = UIStackView()
            varationStack.axis = .vertical
            
            // Create the labels based on the possible variations of the word form, most words will consist of a single varation but there are predictable exceptions
            let varationsLabels = viewModel.getWordFormVariations(for: row)
                .map { varation in
                    let label = UILabel()
                    label.text = varation
                    label.adjustsFontSizeToFitWidth = true
                    return label
                }
            
            for varationsLabel in varationsLabels {
                varationStack.addArrangedSubview(varationsLabel)
            }
            
            if varationsLabels.isEmpty { // there will be no variations for the top left corner of the grid, but an empty label is still required for anchoring
                let label = UILabel()
                varationStack.addArrangedSubview(label)
            }
            
            return varationStack
        }
    }
}
