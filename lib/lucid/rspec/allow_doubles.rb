require 'rspec/core'

# This file allows you to use all of RSpec's mocking frameworks. This
# essentially allows you to create test doubles which are used to
# stand in place of a production object during execution.

RSpec.configuration.configure_mock_framework
Domain(RSpec::Core::MockFrameworkAdapter)

Before do
  RSpec::Mocks::setup(self)
end

After do
  begin
    RSpec::Mocks::verify
  ensure
    RSpec::Mocks::teardown
  end
end
