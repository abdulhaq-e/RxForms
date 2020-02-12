//
//  FormGroupTests.swift
//  RxForms
//
//  Created by Abdulhaq Emhemmed on 2/6/20.
//

import Foundation
import Quick
import Nimble
import RxBlocking
import RxTest

@testable import RxForms

class FormGroupTests: QuickSpec {
  
  var sut: FormGroup!
  
  override func spec() {
    fdescribe("formGroup") {
      it("should accept a dictionary of controls") {
        self.sut = FormGroup(controls: ["name": FormControl()])
        expect(self.sut.controls?.count) == 1
        expect(self.sut.controls?["name"]).notTo(beNil())
      }
      
      it("should set updateOn if provided  in options") {
        expect(self.sut.updateOn) == .change
        self.sut = FormGroup(options: AbstractControlOptions(updateOn: .blur))
        expect(self.sut.updateOn) == .blur
      }
      
      it("should set parent of all child controls") {
        self.sut = FormGroup(controls: ["name": FormControl(), "password": FormControl()])
        expect(self.sut.controls?["name"]?.parent).notTo(beNil())
        expect(self.sut.controls?["password"]?.parent).notTo(beNil())
      }
    }
  }
  
}

