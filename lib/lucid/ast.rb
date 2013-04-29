require 'lucid/ast/comment'
require 'lucid/ast/features'
require 'lucid/ast/feature'
require 'lucid/ast/background'
require 'lucid/ast/scenario'
require 'lucid/ast/scenario_outline'
require 'lucid/ast/step_invocation'
require 'lucid/ast/step_collection'
require 'lucid/ast/step'
require 'lucid/ast/table'
require 'lucid/ast/tags'
require 'lucid/ast/doc_string'
require 'lucid/ast/outline_table'
require 'lucid/ast/examples'
require 'lucid/ast/tree_walker'

module Lucid
  # Classes in this module represent the Abstract Syntax Tree (AST)
  # that gets built when feature files are parsed.
  #
  # AST classes don't expose any internal data directly. This is
  # in order to encourage a less coupled design in the classes
  # that operate on the AST. The only public method is #accept.
  #
  # The AST can be traversed with a visitor. See Lucid::Format::Standard
  # for an example.
  module Ast
  end
end
