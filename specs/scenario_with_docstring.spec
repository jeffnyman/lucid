Ability: Support Docstrings

  Scenario: Steps with a Docstring
    Given the following text:
    """
    'The time has come,' the Walrus said,
    'To talk of many things:
    Of shoes--and ships--and sealing-wax--
    Of cabbages--and kings--
    And why the sea is boiling hot--
    And whether pigs have wings.'
    """
    Then the first four words are "The time has come"
