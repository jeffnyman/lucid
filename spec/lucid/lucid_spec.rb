require 'spec_helper'

describe Lucid do
  it 'will return version information' do
    expect(Lucid.version).to eq "Lucid v#{Lucid::VERSION}"
  end
end
