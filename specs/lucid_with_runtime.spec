Feature: Run Lucid with Runtime
  
  Scenario: Pass a Test Spec to Lucid
    Given a file named "specs/lucid.spec" with:
    """
    Feature:
      Scenario:
        Given lucid works
    """
    Given a file named "specs/steps/lucid_steps.rb" with:
    """
    Given (/^lucid works$/) {}
    """
    When the following code is executed:
    """
    require 'lucid'
    runtime = Lucid::Runtime.new
    runtime.load_code_language('rb')
    Lucid::CLI::App.new([]).start(runtime)
    """
    Then the scenario should pass
    And  the output should contain:
    """
    Given lucid works
    """