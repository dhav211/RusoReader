struct Chapter {
    var name: String
    var index: Int
    var currentUserProgress: Int
    var text: String
    
    init(name: String, index: Int, currentUserProgress: Int, text: String) {
        self.name = name
        self.index = index
        self.currentUserProgress = currentUserProgress
        self.text = text
    }
}
