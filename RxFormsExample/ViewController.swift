//
//  ViewController.swift
//  TestApp
//
//  Created by Abdulhaq Emhemmed on 7/8/19.
//  Copyright © 2019 Umbrella Financial Services LLC. All rights reserved.
//

import UIKit
import MaterialComponents
import SnapKit
@testable
import RxForms

class ViewController: UIViewController {
  
  lazy var customView = self.view as! ViewControllerView
  
  override func loadView() {
    self.view = ViewControllerView()
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let formControl = FormControl(options: AbstractControlOptions(validators: [{
     c in
      if (c.value as? String)?.lowercased().starts(with: "a") ?? false {
        return nil
      }
      
      return ["wrongValue": "does not start with a"]
      }], updateOn: .blur))
    let controlDirective = FormControlDirective.init(form: formControl, valueAccessors: TextFieldValueAccessor.init(element: self.customView.nameTextField, elementController: self.customView.controller))
    formControl.setValue(value: "testValue")
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.customView.setConstraints()
  }
}

