//
//  s.swift
//  RxForms
//
//  Created by Abdulhaq Emhemmed on 2/9/20.
//

import UIKit
import RxSwift

public class SwitchValueAccessor: ControlValueAccessor {

  var element: UISwitch
  private var _onChange: onChangeFn = { _ in ()}
  private var disposeBag = DisposeBag()


  public init(element: UISwitch) {
    self.element = element
    
    let subscription = self.element.rx.isOn.asDriver().drive(onNext: {
      self._onChange($0)
    })
      
    subscription.disposed(by: self.disposeBag)
  }
  
  public func writeValue(value: Any?) {
    self.element.setOn(value as! Bool, animated: true)
  }
  
  public func registerOnChange(fn: @escaping onChangeFn) {
    self._onChange = fn
  }
  
  public func registerOnTouched(fn: Any) {
    
  }
  
  public func setDisabledState(isDisabled: Bool) {
    self.element.isEnabled = isDisabled
  }
  
  
}
