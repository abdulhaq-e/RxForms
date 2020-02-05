////
////  FormControl.swift
////  iCash
////
////  Created by Abdulhaq Emhemmed on 12/31/19.
////
//
import UIKit
import RxSwift
import RxCocoa

public typealias ValidatorFn = ((_: AbstractControl) -> ValidationErrors?)
public typealias AsyncValidatorFn = ((_: AbstractControl) -> Observable<ValidationErrors?>)

public typealias onChangeFn = ((_: Any?) -> Void)

struct ControlEventOptions {
  var emitEvent: Bool? = nil
  var onlySelf: Bool? = nil
  
  init(emitEvent: Bool) {
    self.emitEvent = emitEvent
  }
  
  init(onlySelf: Bool) {
    self.onlySelf = onlySelf
  }
  
  init(emitEvent: Bool, onlySelf: Bool) {
    self.emitEvent = emitEvent
    self.onlySelf = onlySelf
  }
}

public struct AbstractControlOptions {
  var validators: [ValidatorFn]?
  var asyncValidators: [AsyncValidatorFn]?
  var updateOn: FormHook?
  
  init(validator: ValidatorFn? = nil, asyncValidator: AsyncValidatorFn? =  nil, updateOn: FormHook? = nil) {
    if let validator = validator {
      self.validators = [validator]
    }
    
    if let asyncValidator = asyncValidator {
      self.asyncValidators = [asyncValidator]
    }
    
    if let updateOn = updateOn {
      self.updateOn = updateOn
    }
  }
  
  init(validators: [ValidatorFn]? = nil, asyncValidators: [AsyncValidatorFn]? =  nil, updateOn: FormHook? = nil) {
    if let validators = validators {
      self.validators = validators
    }
    
    if let asyncValidators = asyncValidators {
      self.asyncValidators = asyncValidators
    }
    
    if let updateOn = updateOn {
      self.updateOn = updateOn
    }
  }
}

func coerceControlOptionsToValidator(options: AbstractControlOptions?) -> ValidatorFn? {
  
  guard let options = options else {
    return nil
  }
  
  guard let validators = options.validators else {
    return nil
  }
  
  return composeValidators(validators: validators)
}

func coerceControlOptionsToAsyncValidator(options: AbstractControlOptions?) -> AsyncValidatorFn? {
  
  guard let options = options else {
    return nil
  }
  
  guard let asyncValidators = options.asyncValidators else {
    return nil
  }
  
  return composeAsyncValidators(asyncValidators: asyncValidators)
}


protocol AbstractControlProtocol {

  var value: Any? { get }
  var parent: FormGroup? { get }
  var status: ControlStatus { get }
  var valid: Bool { get }
  var invalid: Bool { get }
  var pending: Bool { get }
  var disabled: Bool { get }
  var enabled: Bool { get }
  var errors: ValidationErrors? { get }
  var pristine: Bool { get }
  var dirty : Bool { get }
  var touched: Bool { get }
  var untouched: Bool { get }
//  var valueChanges: Observable<Any?> { get }
//  var statusChanges: Observable<ControlStatus> { get }
  var updateOn: FormHook { get }
//  var root: AbstractControl { get }
//
//  func setValidators(newValidators: [ValidatorFn]?)
//  func setAsyncValidators(newValidators: [AsyncValidatorFn]?)
//
//
  func markAsTouched(eventOptions: ControlEventOptions?)
//  func markAllAsTouched()
  func markAsUntouched(eventOptions: ControlEventOptions?)
  func markAsDirty(eventOptions: ControlEventOptions?) // onlySelf: Bool)
  func markAsPristine(eventOptions: ControlEventOptions?)
//  func markAsPending(onlySelf: Bool, emitEvent: Bool)
  func disable(eventOptions: ControlEventOptions?)
  func enable(eventOptions: ControlEventOptions?)
  func setValue(value: Any?, eventOptions: ControlEventOptions?, emitModelToViewChange: Bool)
  func patchValue(value: Any?, eventOptions: ControlEventOptions?, emitModelToViewChange: Bool)
  func updateValueAndValidity(eventOptions: ControlEventOptions?)
  func setParent(parent: FormGroup)
  func reset(formState: FormState?, eventOptions: ControlEventOptions?)
  func setErrors(errors: ValidationErrors?, eventOptions: ControlEventOptions?)
//  func get(path: String) -> AbstractControl?
  func getError(errorCode: String, path: String?) -> Any?
  func hasError(errorCode: String, path: String?) -> Bool
  func registerOnDisabledChange(fn: @escaping((_ isDisabled: Bool) -> Void))
//
}

extension AbstractControlProtocol {
  var valid: Bool {
    return self.status == .valid
  }

  var invalid: Bool {
    return self.status == .invalid
  }

  var pending: Bool {
    return self.status == .pending
  }

  var disabled: Bool {
    return self.status == .disabled
  }

  var enabled: Bool {
    return !self.disabled
  }

  var dirty: Bool {
    return !self.pristine
  }

  var untouched: Bool {
    return !self.touched
  }
//
//  var root: AbstractControl {
//    var x = self
//
//    while x.parent != nil {
//      x = x.parent as! Self
//    }
//
//    return x
//  }
}

public class AbstractControl: AbstractControlProtocol {
  var _pendingDirty : Bool = false
  var _pendingTouched: Bool = false
  private var _updateOn: FormHook? = nil
  private var _parent: FormGroup? = nil
  private var _asyncValidationSubscription: Disposable? = nil
  fileprivate var _value: Any? = nil
  private var _pristine: Bool = true
  private var _status: ControlStatus = .valid
  private var _errors: ValidationErrors? = nil
  private var _touched: Bool = false
//
//  private var _statusChangesRelay: PublishRelay<ControlStatus>
//  private var _valueChangesRelay: PublishRelay<Any?>

  //  fileprivate var _onCollectionChange: (() -> ()) = {}
  fileprivate var _onDisabledChange: [((_ isDisabled: Bool) -> Void)] = []

  var validator: ValidatorFn?
  var asyncValidator: AsyncValidatorFn?

  init(validator: ValidatorFn?, asyncValidator: AsyncValidatorFn?) {
    self.validator = validator
    self.asyncValidator = asyncValidator
//    self._initializeRelays()
  }

  var value: Any? {
    return self._value
  }

  var pristine: Bool {
    return self._pristine
  }

  var parent: FormGroup? {
    return self._parent
  }

  var status: ControlStatus {
    return self._status
  }

  var touched: Bool {
    return self._touched
  }

  var errors: ValidationErrors? {
    return self._errors
  }
  
//  var statusChanges: Observable<ControlStatus>
//  var valueChanges: Observable<Any?>
//  var statusChanges: Observable<ControlStatus>

//  var valueChanges: Observable<Any?>

  var updateOn: FormHook {
    if let u = self._updateOn {
      return u
    }

//    if let parent = self.parent {
//      return parent.updateOn
//    }

    return .change
  }

  func disable(eventOptions: ControlEventOptions? = nil) {
    
    let emitEvent: Bool = eventOptions?.emitEvent ?? true
//    var onlySelf: Bool = eventOptions?.onlySelf ?? false
    
//    let skipPristineCheck = self._parentMarkedDirty(onlySelf: onlySelf)

    self._status = .disabled
    self._errors = nil
//    self._forEachChild { $0.disable(onlySelf: true, emitEvent: emitEvent)}

    self._updateValue()

    if emitEvent {
//      self._statusChangesRelay.accept(self.status)
//      self._valueChangesRelay.accept(self.value)
    }

//    self._updateAncestors(onlySelf: onlySelf, emitEvent: emitEvent, skipPristineCheck: skipPristineCheck)
    self._onDisabledChange.forEach { $0(true) }
  }
  
  func registerOnDisabledChange(fn: @escaping ((Bool) -> Void)) {
  }
  
  func enable(eventOptions: ControlEventOptions? = nil) {
    
//    let emitEvent: Bool = eventOptions?.emitEvent ?? true
    //    var onlySelf: Bool = eventOptions?.onlySelf ?? false
//    let skipPristineCheckt = self._parentMarkedDirty(onlySelf: onlySelf)

    self._status = .valid
//    self._forEachChild { $0.enable(onlySelf: true, emitEvent: emitEvent)}
    self.updateValueAndValidity()

//    self._updateAncestors()
    self._onDisabledChange.forEach { $0(false) }
  }
  
  func patchValue(value: Any?, eventOptions: ControlEventOptions? = nil, emitModelToViewChange: Bool = true) {
  }
  
  func updateValueAndValidity(eventOptions: ControlEventOptions? = nil) {
      
      let emitEvent : Bool = eventOptions?.emitEvent ?? true
  //  var onlySelf: Bool = eventOptions?.onlySelf ?? false
    
      self._setInitialStatus()
      self._updateValue()

      if (self.enabled) {
        self._cancelExistingSubscription()
        self._errors = self._runValidator()
        self._status = self._calculateStatus()

        if (self.status == .valid || self.status == .pending) {
          self._runAsyncValidator(emitEvent: emitEvent)
        }
      }

      if emitEvent {
//        self._valueChangesRelay.accept(self.value)
//        self._statusChangesRelay.accept(self.status)
      }
      
  //    if let parent = self.parent, !onlySelf {
  //      parent._updateValueAndValidity(eventOptions: ControlEventOptions)
  //    }
    }

  
//
//  func setValidators(newValidators: [ValidatorFn]?) {
//    if let validators = newValidators {
//      self.validator =  Validators.compose(validators: validators)
//    } else {
//      self.validator = nil
//    }
//
//  }
//
//  func setAsyncValidators(newValidators: [AsyncValidatorFn]?) {
//    if let validators = newValidators {
//      self.asyncValidator = Validators.composeAsync(validators: validators)
//    } else {
//      self.asyncValidator = nil
//    }
//  }
//
//  func clearValidators() {
//    self.validator = nil
//  }
//
//  func clearAsyncValidators() {
//    self.asyncValidator = nil
//  }


  func markAsTouched(eventOptions: ControlEventOptions? = nil) {
//    let onlySelf: Bool =  eventOptions?.onlySelf ?? false
    self._touched = true

//    if let parent = self.parent, !onlySelf {
//      parent.markAsTouched()
//    }
  }

//  func markAllAsTouched() {
//    self.markAsTouched(onlySelf: true)
//
//    self._forEachChild { $0.markAllAsTouched() }
//  }
//
  func markAsUntouched(eventOptions: ControlEventOptions?) {
    self._touched = false
    self._pendingTouched = false

//    self._forEachChild { $0.markAsUntouched(eventOptions: eventOptions)}

//    if let parent = self.parent, onlySelf {
//      parent.markAsUntouched(eventOptions: eventOptions)
//    }
  }

  func markAsDirty(eventOptions: ControlEventOptions? = nil) {
//    let onlySelf: Bool =  eventOptions?.onlySelf ?? false
    self._pristine = false

//    if let parent = self.parent, onlySelf {
//      parent.markAsDirty(onlySelf: onlySelf)
//    }
  }

  func markAsPristine(eventOptions: ControlEventOptions?) {
    // let onlySelf: Bool =  eventOptions?.onlySelf ?? false
    self._pristine = true
    self._pendingDirty = false

//    self._forEachChild { $0.markAsPristine(onlySelf: true)}

//    if let parent = self.parent, onlySelf {
//      parent.markAsPristine(eventOptions: eventOptions)
//    }
}

//  func markAsPending(onlySelf: Bool = false, emitEvent: Bool = true) {
//    self._status = .pending
//
//    if emitEvent {
//      self._statusChangesRelay.accept(self.status)
//    }
//
//    if (self.parent != nil && !onlySelf) {
//      self.parent!.markAsPending(onlySelf: false, emitEvent: emitEvent)
//    }
//  }
  
  func setParent(parent: FormGroup) {
    self._parent = parent
  }
  
  func setValue(value: Any?, eventOptions: ControlEventOptions? = nil, emitModelToViewChange:  Bool = true) {
  }
  
  func reset(formState: FormState? = nil, eventOptions: ControlEventOptions? = nil) {
    
  }

  func setErrors(errors: ValidationErrors?, eventOptions: ControlEventOptions? = nil) {
    let emitEvent: Bool = eventOptions?.emitEvent ?? true
    print("error set")
    self._errors = errors
    
    self._updateControlsErrors(emitEvent: emitEvent)
  }

//  func get(path: String) -> AbstractControl? {
//    return nil
//  }

  func getError(errorCode: String, path: String? = nil) -> Any? {
//    let control = (path == nil) ? self : self.get(path: path!)

//    if let control = control, let errors = control.errors, let error = errors[errorCode] {
//      return error
//    }
    
    if let error = self.errors?[errorCode] {
      return error
    }

    return nil
  }

  func hasError(errorCode: String, path: String?) -> Bool {
    return self.getError(errorCode: errorCode, path: path) != nil
  }
}

extension AbstractControl {

  func _forEachChild(_: ((_: AbstractControl) -> ())) {}
  func _anyControls(condition: ((_: AbstractControl) -> Bool)) -> Bool { return false }

  func _anyControlsHaveStatus(status: ControlStatus) -> Bool {
    return self._anyControls { (control: AbstractControl) in
      return control.status == status
    }
  }

  func _anyControlsDirty() -> Bool {
    return self._anyControls{ (control: AbstractControl) in
      return control.dirty
    }
  }

  func _anyControlsTouched() -> Bool {
    return self._anyControls { (control: AbstractControl) in
      return control.touched
    }
  }

  func _allControlsDisabled() -> Bool {
    return self.disabled
  }
  
  @objc func _syncPendingControls() -> Bool {
    return true
  }

  func _calculateStatus() -> ControlStatus {
    if self._allControlsDisabled() { return .disabled }
    if self.errors != nil {return .invalid}
//    if self._anyControlsHaveStatus(status: .pending) {return .pending}
//    if self._anyControlsHaveStatus(status: .invalid) {return .invalid}
    return .valid;
  }

  func _updateTouched(eventOptions: ControlEventOptions? = nil) {
//    let onlySelf: Bool = eventOptions?.onlySelf ?? true
    
    self._touched = self._anyControlsTouched()

//    if let parent = self.parent, !onlySelf {
//      parent._updateTouched(eventOptions: eventOptions)
//    }
  }

  func _updatePristine(eventOptions: ControlEventOptions? = nil) {
//    let onlySelf: Bool = eventOptions?.onlySelf ?? true

    self._pristine = !self._anyControlsDirty()

//    if let parent = self.parent, !onlySelf {
//      parent._updatePristine(eventOptions: eventOptions)
//    }
  }
  
  func _updateValue() { }

  func _updateControlsErrors(emitEvent: Bool) {
    self._status = self._calculateStatus()

    if emitEvent {
//      self._statusChangesRelay.accept(self.status)
    }
    
//    if let parent = self.parent {
//      parent._updateControlsErrors(emitEvent: emitEvent)
//    }
  }

  func _updateAncestors(skipPristineCheck: Bool, eventOptions: ControlEventOptions) {
//    if let parent = self.parent, !eventOptions.onlySelf {
//      _updateValueAndValidity(onlySelf: onlySelf, emitEvent: emitEvent)
//
//      if !skipPristineCheck {
//        parent._updatePristine()
//      }
//
//      parent._updateTouched()
//    }
  }

//  func _updateTreeValidity(emitEvent: Bool) {
//    self._forEachChild { ($0 as! SharedControl)._updateTreeValidity(emitEvent: emitEvent) }
//    self.updateValueAndValidity(onlySelf: true, emitEvent: emitEvent)
//  }


  func _setInitialStatus() {
    self._status = self._allControlsDisabled() ? .disabled : .valid
  }

  func _parentMarkedDirty(onlySelf: Bool) -> Bool {
    if let parent = self.parent, parent.dirty, !parent._anyControlsDirty(), !onlySelf {
      return true
    }

    return false
  }
  


//  func _registerOnCollectionChange(fn: @escaping (() -> ())) {
//    self._onCollectionChange = fn
//  }
//
  func _runValidator() -> ValidationErrors? {
    
    if let validator = self.validator {
      return validator(self)
    }

    return nil
  }

  func _runAsyncValidator(emitEvent: Bool) {
    if let asyncValidator = self.asyncValidator {
      self._status = .pending
      let obs$ = asyncValidator(self).asObservable()
      self._asyncValidationSubscription = obs$.subscribe(onNext: {
        self.setErrors(errors: $0, eventOptions: ControlEventOptions(emitEvent: emitEvent))
      })
    }
  }

  private func _cancelExistingSubscription() {
    self._asyncValidationSubscription?.dispose()
  }

  fileprivate func _setUpdateStrategy(updateOn: FormHook? = nil) {
    self._updateOn = updateOn
  }
  
  func _initializeRelays() {
//    self._valueChangesRelay = PublishRelay<Any?>()
//    self._statusChangesRelay  = PublishRelay<ControlStatus>()
//    self.statusChanges = self._statusChangesRelay.asObservable()
//    self.valueChanges = self._valueChangesRelay.asObservable()
  }
}

enum ControlStatus {
  case valid, invalid, pending, disabled
}

enum FormHook {
  case change, blur, submit
}

public typealias ValidationErrors = [String: Any]

public class FormState {
  var value: Any
  var disabled: Bool

  init(value: Any, disabled: Bool) {
    self.value = value
    self.disabled = disabled
  }
}

public class FormControl: AbstractControl {

  fileprivate var _onChange: [onChangeFn] = []
  var _pendingValue: Any? = nil
  var _pendingChange: Bool = false

  public init(formState: FormState? = nil, options: AbstractControlOptions? = nil) {
    super.init(validator: coerceControlOptionsToValidator(options: options), asyncValidator: coerceControlOptionsToAsyncValidator(options: options))
//    self._initializeRelays()
    self._setUpdateStrategy(updateOn: options?.updateOn)
    self._applyFormState(formState: formState)
    self.updateValueAndValidity(eventOptions: ControlEventOptions(emitEvent: false, onlySelf: true))
  }
  
  override func setValue(value: Any?, eventOptions: ControlEventOptions? = nil, emitModelToViewChange: Bool = true) {
    self._value = value
    self._pendingValue = value
    
    if !self._onChange.isEmpty, emitModelToViewChange {
      self._onChange.forEach { $0(value) }
    }
    self.updateValueAndValidity(eventOptions: eventOptions)
  }
  
  override func patchValue(value: Any?, eventOptions: ControlEventOptions? = nil, emitModelToViewChange: Bool = true) {
    self.setValue(value: value, eventOptions: eventOptions, emitModelToViewChange: emitModelToViewChange)
  }

  override func reset(formState: FormState? = nil, eventOptions: ControlEventOptions? = nil) {
    self._applyFormState(formState: formState)
    self.markAsPristine(eventOptions: eventOptions)
    self.markAsUntouched(eventOptions: eventOptions)
    self.setValue(value: formState?.value, eventOptions: eventOptions)
    self._pendingChange = false
  }
  
  func registerOnChange(fn: @escaping onChangeFn) {
    self._onChange.append(fn)
  }

  override func registerOnDisabledChange(fn: @escaping ((Bool) -> Void)) {
    self._onDisabledChange.append(fn)
  }


  private func _applyFormState(formState: FormState?) {
    if let formState = formState {
      self._value = formState.value
      self._pendingValue = formState.value
      if formState.disabled {
        self.disable(eventOptions: ControlEventOptions(emitEvent: false, onlySelf: true))
      } else {
        self.enable(eventOptions: ControlEventOptions(emitEvent: false, onlySelf: true))
      }
    }
  }

  private func _clearChangeFns() {
    self._onChange = []
    self._onDisabledChange = []
//    self._onCollectionChange = {}
  }

  override func _syncPendingControls() -> Bool {
    if (self.updateOn == .submit) {
      if (self._pendingDirty) {self.markAsDirty()}
      if (self._pendingTouched) {self.markAsTouched()}
      if (self._pendingChange) {
        self.setValue(value: self._pendingValue, eventOptions: ControlEventOptions(onlySelf: true), emitModelToViewChange: false)
        return true
      }
    }
    return false
  }
  
}

class FormGroup: AbstractControl {

//  private var controls: [String: AbstractControl]

  init(options: AbstractControlOptions? = nil) {
    super.init(validator: nil, asyncValidator: nil)
    self._setUpdateStrategy(updateOn: options?.updateOn)
  }
  
//  init(controls: [String:  AbstractControl], validators: [ValidatorFn]?, asyncValidators: [AsyncValidatorFn]?) {
//    self.controls = controls
//
//    let composedValidators = Validators.compose(validators: validators)
//    let composedAsyncValidators = Validators.composeAsync(validators: asyncValidators)
//    super.init(validator: composedValidators, asyncValidator: composedAsyncValidators)
//    self._setupControls()
//    self.updateValueAndValidity(onlySelf: true, emitEvent: false)
//
//  }
//
//  func registerControl(name: String, control: AbstractControl) -> AbstractControl {
//    if let control = self.controls[name] { return control }
//    self.controls[name] = control
//    control.setParent(parent: self)
//    (control as! SharedControl)._registerOnCollectionChange(fn: self._onCollectionChange)
//    return control
//  }
//
//  func addControl(name: String, control: AbstractControl) {
//    _ = self.registerControl(name: name, control: control)
//    self.updateValueAndValidity()
//    self._onCollectionChange()
//  }
//
//  func removeControl(name: String) {
//    if let control = self.controls[name] {
//      (control as! SharedControl)._registerOnCollectionChange {
//      }
//    }
//
//    self.controls.removeValue(forKey: name)
//    self.updateValueAndValidity()
//    self._onCollectionChange()
//  }
//
//  func setControl(name: String, control: AbstractControl) {
//    if let control = self.controls[name] {
//        (control as! SharedControl)._registerOnCollectionChange {
//        }
//      }
//    self.controls.removeValue(forKey: name)
//    _ = self.registerControl(name: name, control: control)
//    self.updateValueAndValidity()
//    self._onCollectionChange()
//  }
//
//  func contains(name: String) -> Bool {
//    if let control = self.controls[name] {
//      return control.enabled
//    }
//
//    return false
//  }
//
//  override func setValue(value: Any, onlySelf: Bool, emitEvent: Bool) {
//    assert(false, "NOT IMPLEMENTED")
//  }
//
//  override func patchValue(value: Any, onlySelf: Bool, emitEvent: Bool) {
//    assert(false, "NOT IMPLEMENTED")
//  }
//
//  func reset(formState: [String: FormState], onlySelf: Bool, emitEvent: Bool) {
//    self._forEachChild {
//      $1.reset(formState: formState[$0]!, onlySelf: onlySelf, emitEvent: emitEvent)
//    }
//    self._updatePristine(onlySelf: onlySelf)
//    self._updateTouched(onlySelf: onlySelf)
//    self.updateValueAndValidity(onlySelf: onlySelf, emitEvent: emitEvent)
//  }
//
//  func _setupControls() {
//    self._forEachChild {
//      $1.setParent(parent: self)
//      ($1 as! SharedControl)._registerOnCollectionChange(fn: self._onCollectionChange)
//    }
//  }
//
//  override func _allControlsDisabled() -> Bool {
//    for (_, control) in self.controls {
//      if control.enabled {
//        return false
//      }
//    }
//
//    return self.controls.count > 1 || self.disabled
//  }
//
//  func _forEachChild(fn: ((String, AbstractControl) -> ())) {
//    self.controls.forEach {
//      fn($0.key, $0.value)
//    }
//  }
//
}

