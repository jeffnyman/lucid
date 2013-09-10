Feature: Basic Execution

  Scenario: Testing
    Given lucent exists

  Scenario: No Spec Repo Available
    Given a project with no spec repository
    When  the command `lucid` is executed
    Then  it should fail with:
    """
    No such file or directory - specs
    """