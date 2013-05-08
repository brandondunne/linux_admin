require 'spec_helper'

describe LinuxAdmin::Yum do
  it ".create_repo" do
    LinuxAdmin::Common.stub(:run => true)
    expect(described_class.create_repo("some_path")).to be_true
  end

  context ".download_packages" do
    it "with valid input" do
      LinuxAdmin::Common.stub(:run => true)
      expect(described_class.download_packages("some_path", "pkg_a pkg_b", :mirror_type => :package)).to be_true
    end

    it "without mirror type" do
      LinuxAdmin::Common.stub(:run => true)
      expect { described_class.download_packages("some_path", "pkg_a pkg_b") }.to raise_error
    end
  end

  context ".updates_available?" do
    it "check updates for a specific package" do
      LinuxAdmin::Common.should_receive(:run).once.with("yum check-update abc", :return_exitstatus => true).and_return(100)
      expect(described_class.updates_available?("abc")).to be_true
    end

    it "updates are available" do
      LinuxAdmin::Common.stub(:run => 100)
      expect(described_class.updates_available?).to be_true
    end

    it "updates not available" do
      LinuxAdmin::Common.stub(:run => 0)
      expect(described_class.updates_available?).to be_false
    end

    it "other exit code" do
      LinuxAdmin::Common.stub(:run => 255)
      expect { described_class.updates_available? }.to raise_error
    end

    it "other error" do
      LinuxAdmin::Common.stub(:run).and_raise(RuntimeError)
      expect { described_class.updates_available? }.to raise_error
    end
  end

  context ".update" do
    it "no arguments" do
      LinuxAdmin::Common.should_receive(:run).once.with("yum -y update").and_return(0)
      described_class.update
    end

    it "with arguments" do
      LinuxAdmin::Common.should_receive(:run).once.with("yum -y update 1 2 3").and_return(0)
      described_class.update("1 2", "3")
    end
  end
end