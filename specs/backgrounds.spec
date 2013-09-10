Ability: Allow Backgrounds in Spec Files

  If several scenarios in a test spec start with a common context, you can
  use a `Background` to specify the test steps that should be executed
  before each scenario.

  Background:
    Given a file named "specs/spec_with_passing_background.spec" with:
    """
    Feature: Test Spec with a Passing Background
    
    Background:
      Given a code of "THX1138"
    
    Scenario: Valid Background Context
      Then the code is "THX1138"
    """
    And a file named "specs/steps/steps.rb" with:
    """
    Given (/^a code of "(.*?)"$/) do |value|
      @code = value
    end

    Then (/^the code is "(.*?)"$/) do |value|
      @code.should == value
    end
    """

  Scenario: Test Spec with a Passing Background
    When the command `lucid -q specs/spec_with_passing_background.spec` is executed
    Then it should pass with:
    """
    Feature: Test Spec with a Passing Background
    
      Background: 
        Given a code of "THX1138"

      Scenario: Valid Background Context
        Then the code is "THX1138"
    
    1 scenario (1 passed)
    2 steps (2 passed)
    """