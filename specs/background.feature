Ability: Calculate Next Generation Stardates

  Background:
    Given the stardate page

  Scenario: Convert Valid TNG Stardate, Standard Calculation
    When the tng stardate "54868.6" is converted
    Then the calendar year should be "2377"
