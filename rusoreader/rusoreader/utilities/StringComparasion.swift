final class StringComparasion {
    static func compare(_ a: String, _ b: String) -> Int {
        let a = Array(a)
        let b = Array(b)
        
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        
        var previousRow = Array(0...b.count)
        var currentRow = Array(repeating: 0, count: b.count + 1)
        
        for i in 1...a.count {
            currentRow[0] = i
            
            for j in 1...b.count {
                let deletionCost = previousRow[j] + 1
                let insertionCost = currentRow[j - 1] + 1
                let substitutionCost = previousRow[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1)
                
                currentRow[j] = min(deletionCost, insertionCost, substitutionCost)
            }
            
            previousRow = currentRow
        }
        
        return previousRow[b.count]
    }
}
