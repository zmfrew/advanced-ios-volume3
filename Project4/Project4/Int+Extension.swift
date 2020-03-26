extension Int {
    var hasUniqueDigits: Bool {
        let string = String(self)
        let uniqued = Set(string)
        return string.count == uniqued.count
    }
}
