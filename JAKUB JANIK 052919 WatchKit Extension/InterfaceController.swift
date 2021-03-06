import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController
{
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var startBtn: WKInterfaceButton!
    let healthStore = HKHealthStore()
    let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    let heartRateUnit = HKUnit(from: "count/min")
    var heartRateQuery: HKQuery?
    
    override func awake(withContext context: Any?)
    {
        super.awake(withContext: context)
        guard HKHealthStore.isHealthDataAvailable() else
        {
            label.setText("not available")
            return
        }
        
        let dataTypes = Set([heartRateType])
        healthStore.requestAuthorization(toShare: nil, read: dataTypes)
        { (success, error) -> Void in
            guard success else
            {
                self.label.setText("not allowed")
                return
            }
        }
    }
    
    @IBAction func fetchBtnTapped() {
        if let query = heartRateQuery {
            startBtn.setTitle("Start")
            healthStore.stop(query)
            heartRateQuery = nil
        } else {
            let query = createStreamingQuery()
            heartRateQuery = query
            startBtn.setTitle("Stop")
            healthStore.execute(query)
        }
    }
    
    private func createStreamingQuery() -> HKQuery
    {
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: [])
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit))
        { (query, samples, deletedObjects, anchor, error) -> Void in
            self.addSamples(samples: samples)
        }
        query.updateHandler = { (query, samples, deletedObjects, anchor, error) -> Void in
            self.addSamples(samples: samples)
        }
        return query
    }
    
    private func addSamples(samples: [HKSample]?)
    {
        guard let samples = samples as? [HKQuantitySample] else { return }
        guard let quantity = samples.last?.quantity else { return }
        label.setText("\(quantity.doubleValue(for: heartRateUnit))")
    }
}

