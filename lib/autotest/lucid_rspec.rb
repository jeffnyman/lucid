require 'autotest/lucid_mixin'
require 'autotest/rspec'

class Autotest::LucidRspec < Autotest::Rspec
  include LucidMixin
end
