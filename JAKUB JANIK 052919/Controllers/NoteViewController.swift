//
//  NoteViewController.swift
//  PRACA INŻYNIERSKA
//
//  Created by Jakub Janik on 22/06/2021.
//

import Foundation
import UIKit

class NoteViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var noteLabel: UITextView!
    
    

    public var note: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        noteLabel.text = note
    }


}
    
    
    

