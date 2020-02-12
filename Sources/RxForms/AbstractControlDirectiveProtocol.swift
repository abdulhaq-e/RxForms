//
//  ControlDirectiveProtocol.swift
//  iCash
//
//  Created by Abdulhaq Emhemmed on 1/7/20.
//

import Foundation
import RxSwift

protocol AbstractControlDirectiveProtocol {
    
  var control: AbstractControl { get }
  var value: Any? { get }
  var valid: Bool { get }
  var invalid: Bool { get }
  var pending: Bool { get }
  var disabled: Bool { get }
  var enabled: Bool { get }
  var errors: ValidationErrors? { get }
  var pristine: Bool { get }
  var dirty: Bool { get }
  var touched: Bool { get }
  var untouched: Bool { get }
  var status: ControlStatus { get }
//  var statusChanges: Observable<ControlStatus> { get }
//  var valueChanges: Observable<Any?> { get }
  var path: String? { get }
  
  func reset(value: FormState)
  func hasError(errorCode: String, path: String?) -> Bool
  func getError(errorCode: String, path: String?) -> ValidationErrors?
}

extension AbstractControlDirectiveProtocol {
  var value: Any? {
    return self.control.value
  }
  var valid: Bool {
    return self.control.valid
  }
  var invalid: Bool {
    return self.control.invalid
  }
  var pending: Bool {
    return self.control.pending
  }
  var disabled: Bool {
    return self.control.disabled
  }
  var enabled: Bool {
    return self.control.enabled
  }
  var errors: ValidationErrors? {
    return self.control.errors
  }
  var pristine: Bool {
    return self.control.pristine
  }
  var dirty: Bool {
    return self.control.dirty
  }
  var touched: Bool {
    return self.control.touched
  }
  var untouched: Bool {
    return self.control.untouched
  }
  var status: ControlStatus {
    return self.control.status
  }
//  var statusChanges: Observable<ControlStatus> {
//    return self.control.statusChanges
//  }
//  var valueChanges: Observable<Any?> {
//    return self.control.valueChanges
//  }
  var path: [String]? {
    return nil
  }
  
  func reset(value: FormState) {
    self.control.reset(formState: value)
  }
  
  func hasError(errorCode: String, path: String?) -> Bool {
    return self.control.hasError(errorCode: errorCode, path: path)
  }
  func getError(errorCode: String, path: String?) -> ValidationErrors? {
    return self.getError(errorCode: errorCode, path: path)
  }
  
}
