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
import RxSwift

class ViewController: UIViewController {
  
  lazy var customView = self.view as! ViewControllerView
  
  override func loadView() {
    self.view = ViewControllerView()
  }
  
  var formGroup: FormGroup!
  
  var bag = DisposeBag()
  
  var formControl: FormControl!
  var formControl2: FormControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    formControl = FormControl(options: AbstractControlOptions(validators: [{
     c in
      if (c.value as? String)?.lowercased().starts(with: "a") ?? false {
        return nil
      }
      
      return ["wrongValue": "does not start with a"]
      }]))
    let controlDirective = FormControlDirective.init( valueAccessors: TextFieldValueAccessor.init(element: self.customView.nameTextField))
    
    controlDirective.form = formControl
    formControl2 = FormControl(options: AbstractControlOptions(validators: [{
     c in
      if (c.value as? String)?.lowercased().starts(with: "b") ?? false {
        return nil
      }
      
      return ["wrongValue": "does not start with b"]
      }]))
    let controlDirective2 = FormControlDirective.init( valueAccessors: TextFieldValueAccessor.init(element: self.customView.passwordTextField))
    
    controlDirective2.form = formControl2

    self.formGroup = FormGroup(controls: ["name": formControl, "password": formControl2], options: AbstractControlOptions(updateOn: .submit))
    
//    _ = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).do(onNext: { _ in
//      print(self.formGroup.errors, self.formGroup.valid, "hihi")
//      }).subscribe()
    
    self.customView.submitButton.rx.tap.asDriver().drive(onNext: {
      self.formGroup.submit()
      print(self.formControl.errors)
      print(self.formControl2.errors)
    })
  
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.customView.setConstraints()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.formControl.statusChanges.debug("vcdebug").drive(onNext: { status in
      print("hi hi", status)
      if status == .invalid {
        self.customView.controller.setErrorText("bla bla bla", errorAccessibilityValue: nil)
      } else {
        self.customView.controller.setErrorText(nil, errorAccessibilityValue: nil)
      }
    }).disposed(by: self.bag)
  }
}

