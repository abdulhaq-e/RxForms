////
////  TestVC.swift
////  iCash
////
////  Created by Abdulhaq Emhemmed on 1/8/20.
////
//
//import UIKit
//
//class TestViewController: UIViewController {
//  
//  var textField: UITextField!
//  
//  var textFieldFC = FormControl(formState: FormState(value: "", disabled: false), validators: [], asyncValidators: [])
//  lazy var textFieldFCD = FormControlDirective(form: self.textFieldFC, valueAccessors: [DefaultValueAccessor(element: self.textField)])
//  
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    self.view.backgroundColor = .white
//    self.textField = UITextField().with {
//      self.view.addSubview($0)
//      $0.backgroundColor = .red
//      $0.snp.makeConstraints { make in
//        make.center.equalToSuperview()
//        make.width.equalToSuperview().multipliedBy(0.5)
//      }
//    }
//    _ = self.textFieldFCD
//    self.textFieldFC.valueChanges.subscribe(onNext: {
//      print("hihi")
//      print($0)
//    })
//  }
//  
//  override func viewDidLayoutSubviews() {
//    super.viewDidLayoutSubviews()
//
//  }
//  
//}
//
