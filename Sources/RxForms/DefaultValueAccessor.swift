//
//  DefaultValueAccessor.swift
//  iCash
//
//  Created by Abdulhaq Emhemmed on 1/8/20.
//

import UIKit
import MaterialComponents
import RxSwift

public class TextFieldValueAccessor: ControlValueAccessor {
  private var _onChange: onChangeFn = { _ in ()}
  private var _onTouched: (() -> ()) = {}
  
  private var element: MDCTextField
  private var elementController: MDCTextInputController
  
  private var disposeBag = DisposeBag()
  
  public init(element: MDCTextField, elementController: MDCTextInputController) {
    self.element = element
    self.elementController = elementController
    
   let subscription = self.element.rx.text.asDriver().drive(onNext: { self._onChange($0)})
    
    subscription.disposed(by: self.disposeBag)
    
    let subscription2 = self.element.rx.controlEvent(.editingDidEnd).asDriver().debug().drive(onNext: {
      self._onTouched()
    })
    
    subscription2.disposed(by: self.disposeBag)
  }
  
  public func writeValue(value: Any?) {
    
    self.element.text  = value as? String
  }
  
  public func registerOnChange(fn: @escaping onChangeFn) {
    
    self._onChange = fn
  }
  
  public func registerOnTouched(fn: Any) {
    self._onTouched = fn as! (() -> ())
  }
  
  public func setDisabledState(isDisabled: Bool) {
      self.element.isEnabled = !isDisabled
  }
  
  public func writeError(error: ValidationErrors?) {
    self.elementController.setErrorText(error?.first?.value as? String, errorAccessibilityValue: "")
  }
}

//class DefaultValueAccessor<T>: ControlValueAccessor {
//
//  private var element: T
//
//  init(element: T) {
//    self.element = element
//
//    if let element = element as? UITextField {
//
//      print("printprint")
//      _ = element.rx.text.subscribe(onNext: { val in
//        print("valval", val)
//        self._onChange(val!)
//      })
//    }
//
//  }
//
//  private var _onChange: ((Any) -> ()) = { _ in ()}
//  private var _onTouched: (() -> ()) = {}
//
//  func writeValue(value: Any) {
//    if T.self == UITextField.self {
//      (self.element as! UITextField).text = value as? String
//    }
//  }
//
//  func registerOnChange(fn: Any) {
//
//    self._onChange = fn as! ((Any) -> ())
//  }
//
//  func registerOnTouched(fn: Any) {
//    self._onTouched = fn as! (() -> ())
//  }
//
//  func setDisabledState(isDisabled: Bool) {
//    if T.self == UITextField.self {
//      (self.element as! UITextField).isEnabled = !isDisabled
//    }
//  }
//
//}
