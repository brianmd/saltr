require 'spec_helper'

puts "\n\n\n\n\n\n\n"

describe Saltr::Repl do
  before(:all) {
    @saltr = Saltr::Repl.new
    @result = @saltr.run_yaml('uname -a')
  }
  
  it 'should show all minions' do
    expect(@saltr.minions).to eq('*')
  end
  
  describe 'should process a simple command' do
    it 'has at least one minion result' do
      expect(@result.keys.size).to be >=1
    end
    
    it 'has returns the correct elements' do
      first = @result[@result.keys.first]
      expect(first.keys.sort).to eq(['pid','retcode','stderr', 'stdout'])
    end
  end
  
  describe 'can set minion' do
    it 'to first minion' do
      first_minion = @result.keys.first
      one = @saltr.run("minions=#{first_minion}")
      expect(one).to eq(first_minion)
      expect(@saltr.minions).to eq(first_minion)
      result = @saltr.run_yaml('uname -a')
      expect(result.size).to eq(1)
    end
  end
end
