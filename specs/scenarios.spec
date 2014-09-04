Ability: Store Manual Tests in Repository
  Scenario: Matching Terms with Quoted Parameters
    When looking up the definition of "CHUD"
    Then the result is "Contaminated Hazardous Urban Disposal"
