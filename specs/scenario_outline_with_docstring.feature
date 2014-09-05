Ability: Support Docstrings with Scenario Outlines

  Scenario Outline: a simple outline
    Given the <stardate>
    Then the following is reported:
      """
      Stardate: <stardate>
      """

    Examples:
      | stardate |
      | 46379.1  |
      | 56844.9  |

