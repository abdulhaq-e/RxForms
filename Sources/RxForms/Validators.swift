//
//  Validators.swift
//  iCash
//
//  Created by Abdulhaq Emhemmed on 1/2/20.
//

import Foundation
import RxSwift

class Validators {
  
  
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
