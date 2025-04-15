//
//  OnboardingViewModelTests.swift
//  SwiftMarketingKit
//
//  Created on 15/04/2025.
//

import XCTest
@testable import Onboarding

final class OnboardingViewModelTests: XCTestCase {
    
    func testInitialState() {
        // Given
        let viewModel = OnboardingViewModel()
        
        // Then
        XCTAssertEqual(viewModel.currentStepIndex, 0)
        XCTAssertTrue(viewModel.showOnboarding)
        XCTAssertEqual(viewModel.steps.count, OnboardingStep.sampleSteps.count)
        XCTAssertTrue(viewModel.isFirstStep)
        XCTAssertFalse(viewModel.isLastStep)
    }
    
    func testNextStep() {
        // Given
        let viewModel = OnboardingViewModel()
        
        // When
        viewModel.nextStep()
        
        // Then
        XCTAssertEqual(viewModel.currentStepIndex, 1)
        XCTAssertFalse(viewModel.isFirstStep)
    }
    
    func testPreviousStep() {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.currentStepIndex = 1
        
        // When
        viewModel.previousStep()
        
        // Then
        XCTAssertEqual(viewModel.currentStepIndex, 0)
        XCTAssertTrue(viewModel.isFirstStep)
    }
    
    func testSkipOnboarding() {
        // Given
        let viewModel = OnboardingViewModel()
        
        // When
        viewModel.skipOnboarding()
        
        // Then
        XCTAssertFalse(viewModel.showOnboarding)
    }
    
    func testCompleteOnboarding() {
        // Given
        let viewModel = OnboardingViewModel()
        
        // When
        viewModel.completeOnboarding()
        
        // Then
        XCTAssertFalse(viewModel.showOnboarding)
    }
    
    func testNextStepToCompletion() {
        // Given
        let viewModel = OnboardingViewModel()
        let totalSteps = viewModel.steps.count
        
        // When
        for _ in 0..<totalSteps {
            viewModel.nextStep()
        }
        
        // Then
        XCTAssertFalse(viewModel.showOnboarding)
    }
}
