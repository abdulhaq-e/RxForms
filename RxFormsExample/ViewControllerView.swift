//
//  ViewControllerView.swift
//  RxFormsExample
//
//  Created by Abdulhaq Emhemmed on 1/21/20.
//

import UIKit
import MaterialComponents
import RxForms

class ViewControllerView: UIView {
  
  // MARK: - Controls
  @TextFieldConstraints(maxLength: 10) var nameTextField: MDCTextField!
  var passwordTextField: MDCTextField!
  var submitButton: MDCButton!
  
  var controller: MDCTextInputControllerOutlined!
  var controller2: MDCTextInputControllerOutlined!
  let containerScheme = MDCContainerScheme()
  
  
  var constraintsSet = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .white
    self.createSubviews()
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  func setConstraints() {
    if !self.constraintsSet {
      self.nameTextField.snp.makeConstraints { make in
        make.center.equalToSuperview()
        make.width.equalToSuperview().multipliedBy(0.5)
        
        self.passwordTextField.snp.makeConstraints { make in
          make.width.equalTo(self.nameTextField)
          make.leading.equalTo(self.nameTextField)
          make.top.equalTo(self.nameTextField.snp.bottom).offset(20)
        }
        
        self.submitButton.snp.makeConstraints { make in
         
          make.width.equalTo(self.passwordTextField)
          
         make.leading.equalTo(self.passwordTextField)
          make.top.equalTo(self.passwordTextField.snp.bottom).offset(20)
        }
      }
    }
    self.constraintsSet = true
  }
  
}

private extension ViewControllerView {
  func createSubviews() {
    self.nameTextField = MDCTextField()
    self.nameTextField.placeholder = "Name"
    self.controller = MDCTextInputControllerOutlined(textInput: self.nameTextField)
    self.controller.applyTheme(withScheme: self.containerScheme)
    self.addSubview(self.nameTextField)
    
    self.passwordTextField = MDCTextField()
    self.passwordTextField.placeholder = "Password"
    self.controller2 = MDCTextInputControllerOutlined(textInput: self.passwordTextField)
    self.controller2.applyTheme(withScheme: self.containerScheme)
    self.addSubview(self.passwordTextField)
    
    self.submitButton = MDCButton()
    self.submitButton.setTitle("Submit", for: .normal)
    self.submitButton.applyContainedTheme(withScheme: self.containerScheme)
    self.addSubview(self.submitButton)
  }
}


