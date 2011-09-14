require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


  describe GoldenBrindle::Registry do

    let(:commands) do
      ["start", "stop", "restart", "configure", "cluster::start", "cluster::stop", "cluster::restart"]
    end

    it "constantize should return proper constant" do
      GoldenBrindle::Registry.constantize("GoldenBrindle::Registry").should eql GoldenBrindle::Registry
    end

    it "constantize should raise on broken constant" do
      expect { GoldenBrindle::Registry.constantize("GoldenBrindle::Registry123")}.to raise_error
    end

    it "commands should return correct commands" do
      GoldenBrindle::Registry.commands.should =~ commands
    end


  end
