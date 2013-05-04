require 'autotest/lucid_mixin'
require 'autotest/rails_rspec'

class Autotest::LucidRailsRspec < Autotest::RailsRspec
  include LucidMixin
end
