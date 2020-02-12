//
//  RxControl.swift
//  iCash
//
//  Created by Abdulhaq Emhemmed on 1/7/20.
//

import Foundation

protocol AbstractControlDirective: AbstractControlDirectiveProtocol {
    
  var name: String { get }
  var valueAccessor: ControlValueAccessor { get }
  
  func viewToModelUpdate(newValue: Any?)
}
