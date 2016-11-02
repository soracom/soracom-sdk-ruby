require 'spec_helper'

describe Soracom do
  it 'has a version number' do
    expect(Soracom::VERSION).not_to be nil
  end

  it 'initialize fails without any credentials' do
    expect { Soracom::Client.new }.to raise_error('Could not find any credentials(apikey or email & password)')
  end

  it 'initialize fails with invalid credentials' do
    expect { Soracom::Client.new(email: 'somebody@example.com', password: 'foobar') }.to raise_error SystemExit
  end

  it 'initialize succeeds with valid credentials' do
    expect { Soracom::Client.new(email: 'REPLACEME', password: 'REPLACEME') }.to raise_error SystemExit
  end
end
