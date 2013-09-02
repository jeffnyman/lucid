Ability: Context Descriptions Within a Feature
  
  Background:
    Given a file named "specs/steps/lucid_steps.rb" with:
    """
    Given (/^lucid works$/) {}
    """
    
  Scenario: All Elements Have a Description
    Given a file named "specs/describe.spec" with:
    """
    Feature: Context Descriptions
      
      A description can be used for the feature. This description
      can span multiple lines.
      
      Background:
        A background context can have descriptive text.
        
        Given lucid works
      
      Scenario:
        A scenario can have descriptive text.
        
        Given lucid works
    """
    When the command `lucid -q` is executed
    Then the error stream should be empty
    Then it should pass with:
    """
    Feature: Context Descriptions
      
      A description can be used for the feature. This description
      can span multiple lines.
    
      Background: 
        A background context can have descriptive text.
        Given lucid works
    
      Scenario: 
        A scenario can have descriptive text.
        Given lucid works
    
    1 scenario (1 passed)
    2 steps (2 passed)
    """
