struct Chapter {
    var name: String
    var index: Int
    var currentUserProgress: Int
    var url: String
    
    init(name: String, index: Int, currentUserProgress: Int, url: String) {
        self.name = name
        self.index = index
        self.currentUserProgress = currentUserProgress
        self.url = url
    }
}
