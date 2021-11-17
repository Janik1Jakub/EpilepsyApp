import Foundation
import UIKit

class MainMenuViewController: UIViewController {
    
    @IBAction func BMIPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCalculateBMI", sender: self)
    }
    
    
    @IBAction func NotePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToNote", sender: self)
    }
    
    @IBAction func TimerPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToTimer", sender: self)
    }
    
    @IBAction func CalendarPressed(_ sender: UIButton)
    {
        performSegue(withIdentifier: "goToCalendar", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
