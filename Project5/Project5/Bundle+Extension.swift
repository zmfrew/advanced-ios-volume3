import Foundation

extension Bundle {
    func decode(from filename: String) -> [Product] {
        let json = url(forResource: filename, withExtension: nil)!
        let jsonData = try! Data(contentsOf: json)
        let result = try! JSONDecoder().decode([Product].self, from: jsonData)
        return result.sorted { $0.name < $1.name }
    }
}
