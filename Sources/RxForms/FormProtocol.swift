import RxSwift
import RxCocoa

public typealias ValidatorFn = ((_: AbstractControl) -> ValidationErrors?)
public typealias AsyncValidatorFn = ((_: AbstractControl) -> Observable<ValidationErrors?>)

public typealias onChangeFn = ((_: Any?) -> Void)

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
  var valueChanges: Driver<Any?> { get }
  var statusChanges: Driver<ControlStatus> { get }
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

protocol AbstractControlInternalProtocol {
    
  func syncPendingControls() -> Bool
  func allControlsDisabled() -> Bool
  func calculateStatus() -> ControlStatus
  func forEachChild(_: ((_: AbstractControl) -> Void))
  func forEachChild(_: ((_: String, _: AbstractControl) -> Void))
  func anyControls(condition: ((_: AbstractControl) -> Bool)) -> Bool
func anyControlsHaveStatus(status: ControlStatus) -> Bool
  func anyControlsDirty() -> Bool
  func anyControlsTouched() -> Bool
  func updateTouched(eventOptions: ControlEventOptions?)
  func updatePristine(eventOptions: ControlEventOptions?)
  func updateValue()
  func updateControlsErrors(emitEvent: Bool)
  func updateAncestors(skipPristineCheck: Bool, eventOptions: ControlEventOptions)
  func setInitialStatus()
  func parentMarkedDirty(onlySelf: Bool) -> Bool
  func runValidator() -> ValidationErrors?
  func runAsyncValidator(emitEvent: Bool)
  func cancelExistingSubscription()
  func setUpdateStrategy(updateOn: FormHook?)
  func initializeRelays()
  func updateTreeValidity(eventOptions: ControlEventOptions?)
}


