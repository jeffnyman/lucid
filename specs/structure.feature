# Features can have comments prior to the actual spec material. Do note
# that it must be commented text. These comments will show up in output.

@manual
Ability: Provide Basic Parts of a Test Spec

  As a test solution writer
  I need the test specs to support narrative
  so that I can allow features to state value

  Notice you can have narrative after the feature/ability title
  and before any scenarios. All narrative shows up in output.

  # A scenario can have a top-level comment. This top-level comment is
  # meant for discussion notes and will show up in output.
  @example
  Scenario: Truth is Truth

    A scenario can have a description. This description can be any
    text that appears after the scenario title but before any steps.
    The description does show up in output.

    # A scenario can have internal comments. These comments are meant
    # to be notes for how to implement the steps and will thus not
    # show up in output.

    * true is almost certainly not false
