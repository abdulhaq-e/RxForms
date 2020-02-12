//
//  TextFieldLengthConstraint.swift
//  RxForms
//
//  Created by Abdulhaq Emhemmed on 2/8/20.
//

import UIKit
import MaterialComponents

public enum TextFieldConstraint {
  case maxLength(length: Int)
  case regex(expression: String)
  case custom(callBack: ((_: String, _ range: NSRange) -> Bool))
}

@propertyWrapper
public class TextFieldConstraints: NSObject, UITextFieldDelegate {
  
  public var wrappedValue: MDCTextField! {
    didSet {
        self.wrappedValue.delegate = self
    }
  }
  private var shouldChangeCharacters: [TextFieldConstraint]
  
  public init(shouldChangeCharactersConstraints: [TextFieldConstraint]) {
    self.shouldChangeCharacters = shouldChangeCharactersConstraints
    super.init()
  }
  
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
   
    if string == "" {
      return true
    }
    
    for constraint in self.shouldChangeCharacters {
      switch constraint {
      case .maxLength(length: let length):
        let condition = (self.wrappedValue.text?.count ?? 0) < length
        
        if !condition {
          return condition
        }
      case .regex(expression: let expression):
        let newstring = self.wrappedValue.text! + string
        return (newstring.range(of: expression, options:.regularExpression) != nil)
      case .custom(callBack: let callBack):
        return callBack(string, range)
      }
    }
    
    return true
  }

}

@propertyWrapper
public class MultilineTextFieldConstraints: NSObject, MDCMultilineTextInputDelegate, UITextViewDelegate {
  
  public var wrappedValue: MDCMultilineTextField! {
    didSet {
        self.wrappedValue.multilineDelegate = self
        self.wrappedValue.textView?.delegate = self
    }
  }
  private var shouldChangeCharacters: [TextFieldConstraint]
  
  public init(shouldChangeCharactersConstraints: [TextFieldConstraint]) {
    self.shouldChangeCharacters = shouldChangeCharactersConstraints
    super.init()
  }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" {
          return true
        }
        
        for constraint in self.shouldChangeCharacters {
          switch constraint {
          case .maxLength(length: let length):
            let condition = (self.wrappedValue.text?.count ?? 0) < length
            
            if !condition {
              return condition
            }
          case .regex(expression: let expression):
            let newstring = self.wrappedValue.text! + text
            return (newstring.range(of: expression, options:.regularExpression) != nil)
          case .custom(callBack: let callBack):
            return callBack(text, range)
          }
        }
        
        return true
    }
}

