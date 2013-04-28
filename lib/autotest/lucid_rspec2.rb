require 'autotest/lucid_mixin'
require 'autotest/rspec2'

class Autotest::LucidRspec2 < Autotest::Rspec2
  include LucidMixin
end
