require 'autotest/rails'
require 'autotest/lucid_mixin'

class Autotest::LucidRails < Autotest::Rails
  include LucidMixin
end
