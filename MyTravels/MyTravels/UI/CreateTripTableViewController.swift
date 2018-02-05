//
//  CreateTripTableViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/4/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class CreateTripTableViewController: UITableViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var chooseStartDateTextField: UITextField!
    @IBOutlet weak var chooseEndDateTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Tap gesture recognizer functions
    
    @IBAction func chooseStartDateTapped(_ sender: UITapGestureRecognizer) {
            
    }
    
    @IBAction func chooseEndDateTapped(_ sender: UITapGestureRecognizer) {
        
    }
    
    // MARK: - Table view data source
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

