//
//  DefaultValueAccessor.swift
//  iCash
//
//  Created by Abdulhaq Emhemmed on 1/8/20.
//

import UIKit
import MaterialComponents
import RxSwift

//@propertyWrapper
//public class MDCTextFieldValueAccessor: ControlValueAccessor {
//
//  public var wrappedValue: MDCTextField!
//  private var elementController: MDCTextInputController
//
//  private var _onChange: onChangeFn = { _ in ()}
//  private var _onTouched: (() -> ()) = {}
//
//  public init(textFieldController: MDCTextInputController) {
//    self.elementController =  textFieldController
//  }
//
//  public func writeValue(value: Any?) {
//
//    self.wrappedValue.text  = value as? String
//  }
//
//  public func registerOnChange(fn: @escaping onChangeFn) {
//
//    self._onChange = fn
//  }
//
//  public func registerOnTouched(fn: Any) {
//    self._onTouched = fn as! (() -> ())
//  }
//
//  public func setDisabledState(isDisabled: Bool) {
//      self.wrappedValue.isEnabled = !isDisabled
//  }
//
//  public func writeError(error: ValidationErrors?) {
//    self.elementController.setErrorText(error?.first?.value as? String, errorAccessibilityValue: "")
//  }
//}

public class MDCTextFieldValueAccessor: ControlValueAccessor {
  private var _onChange: onChangeFn = { _ in ()}
  private var _onTouched: (() -> ()) = {}
  
  private var element: MDCTextField
  
  private var disposeBag = DisposeBag()
  
  public init(element: MDCTextField) {
    self.element = element
    
   let subscription = self.element.rx.text.asDriver().drive(onNext: { self._onChange($0)})
    
    subscription.disposed(by: self.disposeBag)
    
    let subscription2 = self.element.rx.controlEvent(.editingDidEnd).asDriver().drive(onNext: {
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
}


public class MultilineTextFieldValueAccessor: ControlValueAccessor {
  private var _onChange: onChangeFn = { _ in ()}
  private var _onTouched: (() -> ()) = {}
  
  private var element: MDCMultilineTextField
  
  private var disposeBag = DisposeBag()
  
  public init(element: MDCMultilineTextField) {
    self.element = element
    
    let subscription = self.element.textView!.rx.text .asDriver().drive(onNext: { self._onChange($0)})
    
    subscription.disposed(by: self.disposeBag)
    
//    let subscription2 = self.elementCasted.rx. rx.controlEvent(.editingDidEnd).asDriver().drive(onNext: {
//      self._onTouched()
//    })
    
//    subscription2.disposed(by: self.disposeBag)
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
//      self.element.isEditable = false
  }
}
