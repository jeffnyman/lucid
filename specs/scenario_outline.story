Ability: Calculate Next Generation Stardates

  Scenario Outline: Convert Valid TNG Stardates
    Given the stardate page
    When  the tng <stardate> is converted
    Then  the calendar year should be <year>

    Examples:
      | stardate | year | comment      |
      | 46379.1  | 2369 | DS9 begins   |
      | 48315.6  | 2371 | VOY begins   |
      | 56844.9  | 2379 | TNG: Nemesis |
