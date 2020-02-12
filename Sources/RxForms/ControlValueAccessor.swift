//
//  ControlValueAccessor.swift
//  iCash
//
//  Created by Abdulhaq Emhemmed on 1/7/20.
//

import Foundation

public protocol ControlValueAccessor {
    
  func writeValue(value: Any?)
  func registerOnChange(fn: @escaping onChangeFn)
  func registerOnTouched(fn: Any)
  func setDisabledState(isDisabled: Bool)
}
