import UIKit

final class ViewController: UIViewController {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var numberOfRooms: UISegmentedControl!
    @IBOutlet private weak var numberOfBathrooms: UISegmentedControl!
    @IBOutlet private weak var garageCapacity: UISegmentedControl!
    @IBOutlet private weak var condition: UISegmentedControl!
    @IBOutlet private weak var yearBuiltLabel: UILabel!
    @IBOutlet private weak var yearBuiltSlider: UISlider!
    @IBOutlet private weak var sizeLabel: UILabel!
    @IBOutlet private weak var sizeSlider: UISlider!
    @IBOutlet private weak var result: UILabel!
    
    private let model = HousePrices()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let spacing: CGFloat = 30
        stackView.setCustomSpacing(spacing, after: numberOfRooms)
        stackView.setCustomSpacing(spacing, after: numberOfBathrooms)
        stackView.setCustomSpacing(spacing, after: garageCapacity)
        stackView.setCustomSpacing(spacing, after: yearBuiltSlider)
        stackView.setCustomSpacing(spacing, after: sizeSlider)
        stackView.setCustomSpacing(spacing, after: condition)
        
        updatePrediction(self)
    }
    
    @IBAction private func updatePrediction(_ sender: Any) {
        yearBuiltLabel.text = "Year Built: \(Int(yearBuiltSlider.value))"
        sizeLabel.text = "Size: \(Int(sizeSlider.value))"
        
        do {
            let prediction = try model.prediction(rooms: Double(numberOfRooms.selectedSegmentIndex + 1), bathrooms: Double(numberOfBathrooms.selectedSegmentIndex + 1), cars: Double(garageCapacity.selectedSegmentIndex), yearBuilt: Double(Int(yearBuiltSlider.value)), size: Double(Int(sizeSlider.value)), condition: Double(condition.selectedSegmentIndex))
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 0
            result.text = formatter.string(from: prediction.value as NSNumber) ?? ""
        } catch {
            print(error.localizedDescription)
        }
    }
}
