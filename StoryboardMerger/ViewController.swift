//
//  ViewController.swift
//  StoryboardMerger
//
//  Created by Flavio Heleno on 23/10/17.
//  Copyright © 2017 Flavio Heleno. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.progressIndicator.doubleValue = 0.0
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //MARK:- IBActions
    @IBAction func didClickMergeButton(_ sender: Any) {
        let document = self.view.window?.windowController?.document as! Document
        document.merge()
    }

}

