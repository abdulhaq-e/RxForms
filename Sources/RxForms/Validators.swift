//
//  Validators.swift
//  iCash
//
//  Created by Abdulhaq Emhemmed on 1/2/20.
//

import Foundation
import RxSwift

public class Validators {
  
  public static func numbersValidators() -> ValidatorFn {
    
    return { (c: AbstractControl) in
      let value = c.value as? String ?? ""

      return _numbersValidators(text: value)
    }
  }
  
  public static func requiredValidator() -> ValidatorFn {
    
    return { (c: AbstractControl) in
      let value = c.value as? String ?? ""
      if value.isEmpty {
        return ["required": "this field is required"]
      }
      return nil
    }

  }
  
  public static func luhnValidator() -> ValidatorFn {
    
    return { (c: AbstractControl) in
      let value = c.value as? String ?? ""

      if !_luhnCheck(value) {
        return ["luhn": "invalid luhn"]
      }
      
      return nil
    }
  }
  
  public static func exactLength(length: Int) -> ValidatorFn {
    return { (c: AbstractControl) in
      let value = c.value as? String ?? ""

      if value.count != length {
        return ["length": "length is incorrect"]
      }
      
      return nil
    }
  }
  
  public static func minLength(length: Int) -> ValidatorFn {
    return { (c: AbstractControl) in
      let value = c.value as? String ?? ""

      if value.count < length {
        return ["minLength": "length is incorrect"]
      }
      
      return nil
    }
  }
  
  
  
  static func compose(validators: [ValidatorFn]?) -> ValidatorFn? {
    if let validators = validators {
      return { (_ control: AbstractControl) in
        
        return _mergeErrors(arrayOfErrors: _executeValidators(control: control, validators: validators))
      }
    }
    
    return nil

  }
  
  static func composeAsync(validators: [AsyncValidatorFn]?) -> AsyncValidatorFn? {
    if let validators = validators {
      return { (_ control: AbstractControl) in
        let observables$ = _executeAsyncValidators(control: control, validators: validators)
        
        return Observable.zip(observables$).map { _mergeErrors(arrayOfErrors: $0) }
      }
    }
    
    return nil
  }
}

func _executeValidators(control: AbstractControl, validators: [ValidatorFn]) -> [ValidationErrors?] {
  return validators.map { $0(control) }
}

func _executeAsyncValidators(control: AbstractControl, validators: [AsyncValidatorFn]) -> [Observable<ValidationErrors?>] {
  return validators.map { $0(control) }
}

func _mergeErrors(arrayOfErrors: [ValidationErrors?]) -> ValidationErrors? {
  
  return arrayOfErrors.reduce([:]) { (result, error) -> ValidationErrors? in
    
    if error != nil {
      return result?.merging(error!, uniquingKeysWith: { $1 })
    }
    
    return result
  }
}

func _numbersValidators(text: String) -> ValidationErrors? {
  if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: text)) {
    return nil
  }
  
  return ["numbers": "Invalid input, not numbers"]
}

func _luhnCheck(_ number: String) -> Bool {
    var sum = 0
    let digitStrings = number.reversed().map { String($0) }
    
    for tuple in digitStrings.enumerated() {
        if let digit = Int(tuple.element) {
            let odd = tuple.offset % 2 == 1
            
            switch (odd, digit) {
            case (true, 9):
                sum += 9
            case (true, 0...8):
                sum += (digit * 2) % 9
            default:
                sum += digit
            }
        } else {
            return false
        }
    }
    return sum % 10 == 0
}
