//
//  FormControlDirective.swift
//  iCash
//
//  Created by Abdulhaq Emhemmed on 1/7/20.
//

import Foundation

public class FormControlDirective: AbstractControlDirective {

  var viewModel: Any? = nil
  var name: String = ""
  var valueAccessor: ControlValueAccessor
  
  var form: AbstractControl! {
    didSet {
      self.setUpDirective()
    }
  }
  
  var control: AbstractControl {
    return self.form
  }
  
  var path: String? {
    return nil
  }
  
  public init(form: AbstractControl,
    valueAccessors: ControlValueAccessor) {
    self.form = form
    self.valueAccessor = valueAccessors
    self.setUpDirective()
  }
  
  func viewToModelUpdate(newValue: Any?) {
    self.viewModel = newValue
  }
}

extension FormControlDirective {
  func setUpDirective() {
    
    setUpControl(control: self.control as! FormControl, dir: self)
    if self.control.disabled {
      self.valueAccessor.setDisabledState(isDisabled: true)
    }
    
    self.form.updateValueAndValidity(eventOptions: ControlEventOptions(emitEvent: false))
  }
}


func setUpControl(control: FormControl, dir: AbstractControlDirective) {
  
  dir.valueAccessor.writeValue(value: control.value)

  setUpViewChangePipeline(control: control, dir: dir)
  setUpModelChangePipeline(control: control, dir: dir)
  setUpBlurPipeline(control: control, dir: dir)

  control.registerOnDisabledChange(fn: {
    dir.valueAccessor.setDisabledState(isDisabled: $0)
  })
}

func setUpViewChangePipeline(control: FormControl, dir: AbstractControlDirective) {
  dir.valueAccessor.registerOnChange(fn: { (newValue: Any) in
    control._pendingValue = newValue
    control._pendingChange = true
    control._pendingDirty = true
    
    if control.updateOn == .change {
      updateControl(control: control, dir: dir)
    }
  })
}

func setUpModelChangePipeline(control: FormControl, dir: AbstractControlDirective) {
  
  control.registerOnChange(fn: { (newValue: Any) in
    
    dir.valueAccessor.writeValue(value: newValue)
  })
}

func setUpBlurPipeline(control: FormControl, dir: AbstractControlDirective) {
  dir.valueAccessor.registerOnTouched(fn: { () in
    control._pendingTouched = true
    if control.updateOn == .blur && control._pendingChange {
      updateControl(control: control, dir: dir)
    }
    
    if control.updateOn != .submit {
      control.markAsTouched()
    }
  })
}

func updateControl(control: FormControl, dir: AbstractControlDirective) {
  if control._pendingDirty {
    control.markAsDirty()
  }
  
  control.setValue(value: control._pendingValue, emitModelToViewChange: false)
  dir.valueAccessor.writeError(error: control.errors)
  dir.viewToModelUpdate(newValue: control._pendingValue)
  control._pendingChange = false
}
