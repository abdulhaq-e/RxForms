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
  var nameTextField: MDCTextField!
  var controller: MDCTextInputControllerOutlined!
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
  }
}


