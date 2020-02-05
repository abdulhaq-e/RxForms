//
//  Common.swift
//  RxForms
//
//  Created by Abdulhaq Emhemmed on 1/21/20.
//

import Foundation

func composeValidators(validators: [ValidatorFn]) -> ValidatorFn? {
  
  return Validators.compose(validators: validators)
}

func composeAsyncValidators(asyncValidators: [AsyncValidatorFn]) -> AsyncValidatorFn? {
  return Validators.composeAsync(validators: asyncValidators)
}
