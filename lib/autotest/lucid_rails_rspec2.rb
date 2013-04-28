require 'autotest/lucid_mixin'
require 'autotest/rails_rspec2'

class Autotest::LucidRailsRspec2 < Autotest::RailsRspec2
  include LucidMixin
end
