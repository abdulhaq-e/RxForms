//
//  FormControlTests.swift
//  RxForms
//
//  Created by Abdulhaq Emhemmed on 1/21/20.
//

import Foundation
import Quick
import Nimble
import RxBlocking
import RxTest

@testable import RxForms

var requiredValidator : ((_: AbstractControl) -> ValidationErrors?) = { _ in
  return nil
}

class FormControlTests: QuickSpec {
  
  var sut: FormControl!
  
  override func spec() {
    describe("formControl") {
      it("should initialize with nil as default value") {
        self.sut = FormControl()
        
        expect(self.sut.value).to(beNil())
      }
      
      describe("updateOn") {
        it("should be set to 'change' if not specified in initializer nor available in parent") {
          
          self.sut = FormControl()
          
          expect(self.sut.updateOn) == .change
        }
        
        it("should be set to 'change' even  if an option object is passed to the constructor") {
          self.sut = FormControl(formState: nil, options: AbstractControlOptions(validator: requiredValidator))
        }
        
        it("should change with as value is set accordingly") {
          self.sut = FormControl(formState: nil, options: AbstractControlOptions(validator: nil, asyncValidator: nil, updateOn: .blur))
          
          expect(self.sut.updateOn) == .blur
        }
        
//        it("should take the parents value") {
//          let parent = FormGroup(options: AbstractControlOptions(validator: nil, asyncValidator: nil, updateOn: .submit))
//          self.sut = FormControl()
//          expect(self.sut.updateOn) == .change
//
//          self.sut.setParent(parent: parent)
//
//          expect(self.sut.updateOn) == .submit
//        }
      }
      
      describe("dirty") {
        it("should be set to false initially") {
          self.sut = FormControl()
          
          expect(self.sut.dirty).to(beFalse())
        }
        
        it("should be set to true after markAsDirty runs") {
          self.sut = FormControl()
          
          self.sut.markAsDirty()
          expect(self.sut.dirty).to(beTrue())
        }
      }
      
      describe("touched") {
        it("should be set to false initially") {
          self.sut = FormControl()
          expect(self.sut.touched).to(beFalse())
        }
        
        it("should be set to true after markAsTouched") {
          self.sut = FormControl()
          expect(self.sut.touched).to(beFalse())
          self.sut.markAsTouched()
          expect(self.sut.touched).to(beTrue())
        }
      }
      
      describe("disable and enable") {

        it("should mark the control as disabled") {
          self.sut = FormControl()
          expect(self.sut.disabled).to(beFalse())
          expect(self.sut.valid).to(beTrue())

          self.sut.disable()
          expect(self.sut.disabled).to(beTrue())
          expect(self.sut.valid).to(beFalse())

          self.sut.enable()
          expect(self.sut.disabled).to(beFalse())
          expect(self.sut.valid).to(beTrue())
        }
        
        it("should set status to valid and disabled") {
          self.sut = FormControl()
          expect(self.sut.status) == .valid
          
          self.sut.disable()
          expect(self.sut.status) == .disabled
          
          self.sut.enable()
          expect(self.sut.status) == .valid
        }
        
        it("should keep the value when disabled") {
          self.sut = FormControl(formState: FormState(value: "testValue", disabled: false), options: nil)
          
          expect(self.sut.value as? String) == "testValue"
          
          self.sut.disable()
          expect(self.sut.value as? String) == "testValue"

          self.sut.enable()
          expect(self.sut.value as? String) == "testValue"
        }
        
        it("should clear the error when disabled") {
          self.sut = FormControl()
          self.sut.setErrors(errors: ["required": "field is required"])
          expect(self.sut.errors?.count).to(equal(1))
          self.sut.disable()
          expect(self.sut.errors).to(beNil())
        }
        
        xit("should emit status and value by default") {
//          self.sut = FormControl()
//          self.sut.disable()
        }
        
        xit("should not emit status and value when emitEvent is false") {
//         self.sut = FormControl()
//         self.sut.disable()
        }
        
        it("should run functions on disabledChange")  {
          self.sut = FormControl()
          var logDisabled: Int = 0
          var logEnabled: Int = 0
          self.sut.registerOnDisabledChange(fn: {
            if $0 {
              logDisabled += 1
            } else {
              logEnabled += 1
            }
          })
          
          self.sut.disable()
          expect(logDisabled) == 1
          self.sut.enable()
          expect(logEnabled) == 1
        }
      }
      
      describe("setErrors") {
        it("should set errors as given") {
          self.sut = FormControl()
          expect(self.sut.errors).to(beNil())
          self.sut.setErrors(errors: ["required": "whatever"])
          expect(self.sut.errors).notTo(beNil())
          expect(self.sut.errors?.count) == 1
        }
        
        it("should set the status as invalid") {
          self.sut = FormControl()
          
          expect(self.sut.status) == .valid
          self.sut.setErrors(errors: ["a": "b"])
          expect(self.sut.status) == .invalid
        }
      }
      
      describe("setValue") {
        it("should set the value") {
          self.sut = FormControl()
          
          expect(self.sut.value).to(beNil())
          self.sut.setValue(value: "testValue")
          expect(self.sut.value as? String).to(equal("testValue"))
        }
      }
      
      describe("patchValue") {
        it("should act like setValue for FormControl only") {
          self.sut = FormControl()
          
          expect(self.sut.value).to(beNil())
          self.sut.patchValue(value: "testValue")
          expect(self.sut.value as? String).to(equal("testValue"))
        }
      }
      
      describe("reset") {
        it("should reset value") {
          self.sut = FormControl(formState: FormState(value: "testValue", disabled: false))
          
          self.sut.reset()
          expect(self.sut.value).to(beNil())
        }
      }
      
      
//      describe("markAllAsTouched") {
//        it("should mark that control only as touched") {
//          self.sut = FormControl()
//          expect(self.sut.touched).to(beFalse())
//          self.sut.markAllAsTouched()
//          expect(self.sut.touched).to(beTrue())
//        }
//      }
//
//      describe("formstate") {
//        it("should accept a FormState in initilisor and set the correct values") {
//
//        }
//      }
    }
  }
  
}
