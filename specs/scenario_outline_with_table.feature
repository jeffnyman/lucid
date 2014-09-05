Feature: Damage Modifiers with Hit Points

  Scenario Outline: Agility and Critical Modifiers
    Given a hostile NPC with hitpoints and agility:
      | hit points | agility |
      | <hp>       | <agi>   |
    When the NPC suffers <damage> points
    And  there is a <critical> modifier applied
    Then the NPC should be <state>

    Scenarios:
      | hp   | agi | damage | critical | state    |
      | 100  | 10  |  120   | 0        | wounded  |
      | 100  | 0   |  120   | 0        | defeated |
      | 100  | 0   |  10    | 10       | defeated |
