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


public struct ControlEventOptions {
  var emitEvent: Bool? = nil
  var onlySelf: Bool? = nil
  
  public init(emitEvent: Bool) {
    self.emitEvent = emitEvent
  }
  
  public  init(onlySelf: Bool) {
    self.onlySelf = onlySelf
  }
  
  public init(emitEvent: Bool, onlySelf: Bool) {
    self.emitEvent = emitEvent
    self.onlySelf = onlySelf
  }
}

public struct AbstractControlOptions {
  var validators: [ValidatorFn]?
  var asyncValidators: [AsyncValidatorFn]?
  var updateOn: FormHook?
  
  public init(updateOn: FormHook? = nil) {
    self.updateOn = updateOn
    self.validators = nil
    self.asyncValidators = nil
  }
  
  public init(validator: ValidatorFn? = nil, asyncValidator: AsyncValidatorFn? =  nil, updateOn: FormHook? = nil) {
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
  
  public init(validators: [ValidatorFn]? = nil, asyncValidators: [AsyncValidatorFn]? =  nil, updateOn: FormHook? = nil) {
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


public class AbstractControl: AbstractControlProtocol, AbstractControlInternalProtocol {
  
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
  
  private var _statusChangesRelay: PublishRelay<ControlStatus>!
  private var _valueChangesRelay: PublishRelay<Any?>!
  
  //  fileprivate var _onCollectionChange: (() -> ()) = {}
  fileprivate var _onDisabledChange: [((_ isDisabled: Bool) -> Void)] = []
  
  var validator: ValidatorFn?
  var asyncValidator: AsyncValidatorFn?
  
  init(validator: ValidatorFn?, asyncValidator: AsyncValidatorFn?) {
    self.validator = validator
    self.asyncValidator = asyncValidator
    self._statusChangesRelay = PublishRelay()
    self._valueChangesRelay = PublishRelay()
    self.statusChanges = self._statusChangesRelay.asDriver(onErrorRecover: { _ in .empty() })
    self.valueChanges = self._valueChangesRelay.asDriver(onErrorRecover: { _ in .empty() })
//    self.initializeRelays()
  }
  
  public var value: Any? {
    return self._value
  }
  
  var pristine: Bool {
    return self._pristine
  }
  
  var parent: FormGroup? {
    return self._parent
  }
  
  public var status: ControlStatus {
    return self._status
  }
  
  var touched: Bool {
    return self._touched
  }
  
  public var errors: ValidationErrors? {
    return self._errors
  }
  
  //  var statusChanges: Observable<ControlStatus>
  //  var valueChanges: Observable<Any?>
  public var statusChanges: Driver<ControlStatus>
  
  public var valueChanges: Driver<Any?>
  
  var updateOn: FormHook {
    if let u = self._updateOn {
      return u
    }
    
    if let parent = self.parent {
      return parent.updateOn
    }
    
    return .change
  }
  
  public func disable(eventOptions: ControlEventOptions? = nil) {
    
    let emitEvent: Bool = eventOptions?.emitEvent ?? true
    //    var onlySelf: Bool = eventOptions?.onlySelf ?? false
    
    //    let skipPristineCheck = self._parentMarkedDirty(onlySelf: onlySelf)
    
    self._status = .disabled
    self._errors = nil
    //    self._forEachChild { $0.disable(onlySelf: true, emitEvent: emitEvent)}
    
    self.updateValue()
    
    if emitEvent {
    self._statusChangesRelay.accept(self.status)
    self._valueChangesRelay.accept(self.value)
    }
    
    //    self._updateAncestors(onlySelf: onlySelf, emitEvent: emitEvent, skipPristineCheck: skipPristineCheck)
    self._onDisabledChange.forEach { $0(true) }
  }
  
  func registerOnDisabledChange(fn: @escaping ((Bool) -> Void)) {
  }
  
  public func enable(eventOptions: ControlEventOptions? = nil) {
    
//        let emitEvent: Bool = eventOptions?.emitEvent ?? true
//        var onlySelf: Bool = eventOptions?.onlySelf ?? false
//        let skipPristineCheckt = self._parentMarkedDirty(onlySelf: onlySelf)
    
    self._status = .valid
//      self._forEachChild { $0.enable(onlySelf: true, emitEvent: emitEvent)}
    self.updateValueAndValidity(eventOptions: eventOptions)
    
    //    self._updateAncestors()
    self._onDisabledChange.forEach { $0(false) }
  }
  
  func patchValue(value: Any?, eventOptions: ControlEventOptions? = nil, emitModelToViewChange: Bool = true) {
  }
  
  func updateValueAndValidity(eventOptions: ControlEventOptions? = nil) {
    
    let emitEvent : Bool = eventOptions?.emitEvent ?? true
    let onlySelf: Bool = eventOptions?.onlySelf ?? false

    self.setInitialStatus()
    self.updateValue()
    
    if (self.enabled) {
      self.cancelExistingSubscription()
      self._errors = self.runValidator()
      self._status = self.calculateStatus()
      
      if (self.status == .valid || self.status == .pending) {
        self.runAsyncValidator(emitEvent: emitEvent)
      }
    }
            
    if emitEvent {
    self._valueChangesRelay.accept(self.value)
      
        self._statusChangesRelay.accept(self.status)

      
    }
    
//        if let parent = self.parent, !onlySelf {
//          parent.updateValueAndValidity(eventOptions: eventOptions)
//        }
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
  
  public func setValue(value: Any?, eventOptions: ControlEventOptions? = nil, emitModelToViewChange:  Bool = true) {
  }
  
  public func reset(formState: FormState? = nil, eventOptions: ControlEventOptions? = nil) {
    
  }
  
  func setErrors(errors: ValidationErrors?, eventOptions: ControlEventOptions? = nil) {
    let emitEvent: Bool = eventOptions?.emitEvent ?? true
    self._errors = errors
    
    self.updateControlsErrors(emitEvent: emitEvent)
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
  
  // MARK: - Internal Impelmentations
  
  func syncPendingControls() -> Bool {
    return false
  }
  
  func allControlsDisabled() -> Bool {
    return self.disabled
  }
  
  func calculateStatus() -> ControlStatus {
    if self.allControlsDisabled() {
      
      return .disabled }
    if let errors = self.errors, errors.count != 0 {
      
      return .invalid}
    if self.anyControlsHaveStatus(status: .pending) {return .pending}
    if self.anyControlsHaveStatus(status: .invalid) {
      
      return .invalid
      
    }
    return .valid;
  }
  
  func forEachChild(_: ((_: AbstractControl) -> ())) {}
  func forEachChild(_: ((_: String, _: AbstractControl) -> Void)) {}
  func anyControls(condition: ((_: AbstractControl) -> Bool)) -> Bool { return false }
  
  func anyControlsHaveStatus(status: ControlStatus) -> Bool {
    
    return self.anyControls { (control: AbstractControl) in
      return control.status == status
    }
  }
  
  func anyControlsDirty() -> Bool {
    return self.anyControls{ (control: AbstractControl) in
      return control.dirty
    }
  }
  
  func anyControlsTouched() -> Bool {
    return self.anyControls { (control: AbstractControl) in
      return control.touched
    }
  }
  
  func updateTouched(eventOptions: ControlEventOptions? = nil) {
    let onlySelf: Bool = eventOptions?.onlySelf ?? true
    
    self._touched = self.anyControlsTouched()
    
        if let parent = self.parent, !onlySelf {
          parent.updateTouched(eventOptions: eventOptions)
        }
  }
  
  func updatePristine(eventOptions: ControlEventOptions? = nil) {
    
    let onlySelf: Bool = eventOptions?.onlySelf ?? true
    
    self._pristine = !self.anyControlsDirty()
    
        if let parent = self.parent, !onlySelf {
          parent.updatePristine(eventOptions: eventOptions)
        }
  }
  
  func updateValue() { }
  
  func updateControlsErrors(emitEvent: Bool) {
    self._status = self.calculateStatus()
    
    if emitEvent {
      self._statusChangesRelay.accept(self.status)
    }
    
    if let parent = self.parent {
      parent.updateControlsErrors(emitEvent: emitEvent)
    }
  }
  
  func updateAncestors(skipPristineCheck: Bool, eventOptions: ControlEventOptions) {
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
  
  
  func setInitialStatus() {
    self._status = self.allControlsDisabled() ? .disabled : .valid
  }
  
  func parentMarkedDirty(onlySelf: Bool) -> Bool {
    if let parent = self.parent, parent.dirty, !parent.anyControlsDirty(), !onlySelf {
      return true
    }
    
    return false
  }
  
  
  
  //  func _registerOnCollectionChange(fn: @escaping (() -> ())) {
  //    self._onCollectionChange = fn
  //  }
  //
  func runValidator() -> ValidationErrors? {
    
    if let validator = self.validator {
      return validator(self)
    }
    
    return nil
  }
  
  func runAsyncValidator(emitEvent: Bool) {
    if let asyncValidator = self.asyncValidator {
      self._status = .pending
      let obs$ = asyncValidator(self).asObservable()
      self._asyncValidationSubscription = obs$.subscribe(onNext: {
        self.setErrors(errors: $0, eventOptions: ControlEventOptions(emitEvent: emitEvent))
      })
    }
  }
  
  func cancelExistingSubscription() {
    self._asyncValidationSubscription?.dispose()
  }
  
  func setUpdateStrategy(updateOn: FormHook? = nil) {
    self._updateOn = updateOn
  }
  
  func initializeRelays() {
    //    self._valueChangesRelay = PublishRelay<Any?>()
    //    self._statusChangesRelay  = PublishRelay<ControlStatus>()
//    self.statusChanges = self._statusChangesRelay.asObservable()
    //    self.valueChanges = self._valueChangesRelay.asObservable()
  }
  
  func updateTreeValidity(eventOptions: ControlEventOptions?) {
    self.forEachChild { (name: String, control: AbstractControl) in
      control.updateTreeValidity(eventOptions: eventOptions)
    }
    self.updateValueAndValidity(eventOptions: ControlEventOptions(emitEvent: eventOptions?.emitEvent ?? true, onlySelf: true))
  }
}

public enum ControlStatus {
  case valid, invalid, pending, disabled
}

public enum FormHook {
  case change, blur, submit
}

public typealias ValidationErrors = [String: Any]

public class FormState {
  var value: Any?
  var disabled: Bool
  
  public init(value: Any, disabled: Bool) {
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
    self.setUpdateStrategy(updateOn: options?.updateOn)
    self._applyFormState(formState: formState)
    self.updateValueAndValidity(eventOptions: ControlEventOptions(emitEvent: false, onlySelf: true))
  }
  
  override public func setValue(value: Any?, eventOptions: ControlEventOptions? = nil, emitModelToViewChange: Bool = true) {
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
  
  override public func reset(formState: FormState? = nil, eventOptions: ControlEventOptions? = nil) {
    self._applyFormState(formState: formState)
    self.markAsPristine(eventOptions: eventOptions)
    self.markAsUntouched(eventOptions: eventOptions)
    self.setValue(value: formState?.value, eventOptions: eventOptions)
    self._pendingChange = false
  }
  
  public func registerOnChange(fn: @escaping onChangeFn) {
    self._onChange.append(fn)
  }
  
  override public func registerOnDisabledChange(fn: @escaping ((Bool) -> Void)) {
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
  
  
  override func syncPendingControls() -> Bool {
    if self.updateOn == .submit {
      if self._pendingDirty {
        self.markAsDirty()
      }
      if self._pendingTouched {
        self.markAsTouched()
      }
      
      if self._pendingChange {
        
        self.setValue(value: self._pendingValue, eventOptions: ControlEventOptions(onlySelf: true), emitModelToViewChange: false)
        return true
      }
    }
    
    return false
  }
  
}


public class FormGroup: AbstractControl {
  
  public var controls: [String: AbstractControl]?
  
  public init(controls: [String: AbstractControl]? = nil, options: AbstractControlOptions? = nil) {
    super.init(validator: nil, asyncValidator: nil)
    self.controls = controls
    self._setupControls()
    
    self.setUpdateStrategy(updateOn: options?.updateOn)
    self.updateValueAndValidity(eventOptions: ControlEventOptions(emitEvent: false, onlySelf: false))
  }
  
  public func submit() {
    _ = self.syncPendingControls()
    for control in self.controls!.values {
      if control.updateOn == .submit && (control as! FormControl)._pendingChange {
        (control as! FormControl)._pendingChange = false
      }
    }
    self.updateTreeValidity(eventOptions: ControlEventOptions(emitEvent: true))
  }

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
  
  func _setupControls() {
    self.forEachChild { (name: String, control: AbstractControl) in
      
      control.setParent(parent: self)
      //      ($1 as! AbstractControl)._registerOnCollectionChange(fn: self._onCollectionChange)
    }
  }
  
  //  override func _allControlsDisabled() -> Bool {
  //    for (_, control) in self.controls {
  //      if control.enabled {
  //        return false
  //      }
  //    }
  //
  //    return self.controls.count > 1 || self.disabled
  //  }
  
  override func forEachChild(_ fn: ((_: String, _: AbstractControl) -> ())) {
    self.controls?.forEach {
      fn($0.key, $0.value)
    }
  }
  
  override func forEachChild(_ fn: ((AbstractControl) -> ())) {
    self.controls?.forEach {
      fn($0.value)
    }
  }
  
  func _reduceChildren<R>(initialValue: R, fn: ((_ result: R, _ control: AbstractControl) -> R)) -> R {
    
    var res =  initialValue
    self.forEachChild({
      res = fn(res, $1)
    })
    
    return res
    
  }
  
  public func getRawValue() -> [String: Any?] {
    var result: [String:  Any?] = [:]
    
    for control in self.controls! {
      result[control.key] = control.value.value
    }
    
    return result
  }
  
  override func syncPendingControls() -> Bool {
    
    let subtreeUpdated = self._reduceChildren(initialValue: false, fn: {
            
      return $1.syncPendingControls() ? true : $0
      
    })
        
    if subtreeUpdated {
      self.updateValueAndValidity(eventOptions: ControlEventOptions(onlySelf: true))
    }
    
    return subtreeUpdated
    
  }
  
  override func allControlsDisabled() -> Bool {
    if let controls = self.controls?.values {
      for control in controls {
        if control.enabled {
          return false
        }
      }
    }
    
    return self.disabled
  }
  
  override func anyControls(condition: ((AbstractControl) -> Bool)) -> Bool {
    return self.controls!.map { $0.value }.first(where: { $0.enabled && condition($0)}) != nil
  }
  
}

//extension FormGroup: AbstractControlInternalProtocol {
//
//}

