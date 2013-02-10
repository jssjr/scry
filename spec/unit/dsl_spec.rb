require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe Scry::Dsl do

  before(:each) do
    Scry.init
  end
  describe "evaluate" do
    it "should evaluate valid Scryfile contents" do
      lambda { described_class.evaluate_scryfile(:scryfile_contents => valid_scryfile_string) }.should_not raise_error
      described_class.scryfile_contents.should == valid_scryfile_string
    end
  end

  describe "source" do
    before(:each) { Scry.init }
    it "calls add_source from a source directive" do
      Scry.should_receive(:add_source).with('/tmp/test.yml', {})
      described_class.evaluate_scryfile(:scryfile_contents => 'source "/tmp/test.yml"')
    end
    it "should add the source file to the sourcefile list" do
      described_class.evaluate_scryfile(:scryfile_contents => 'source "/tmp/test.yml"')
      Scry.sources.should eq(['/tmp/test.yml'])
    end
  end

  describe "namespace" do
    before(:each) { Scry.init }
    it "calls add_namespace from a namespace directive" do
      Scry.should_receive(:add_namespace).with('app', {:current_namespace=>[]})
      described_class.evaluate_scryfile(:scryfile_contents => 'namespace "app"')
    end
    it "add the namespace name as a key in the scry config data" do
      described_class.evaluate_scryfile(:scryfile_contents => 'namespace "app"')
      Scry['app'].should be_a_kind_of(Scry::DataNode)
    end
    it "should allow for nested namespace calls" do
      described_class.evaluate_scryfile(:scryfile_contents => "namespace 'app' do\n  namespace 'mail'\nend")
      Scry['app'].should be_a_kind_of(Scry::DataNode)
      Scry['app']['mail'].should be_a_kind_of(Scry::DataNode)
    end
  end

  describe "param" do
    before(:each) { Scry.init }
    it "calls add_param from a param directive" do
      Scry.should_receive(:add_param).with('domain', {:current_namespace=>[]})
      described_class.evaluate_scryfile(:scryfile_contents => 'param "domain"')
    end
    it "should set a top level parameter" do
      described_class.evaluate_scryfile(:scryfile_contents => 'param "domain"')
      Scry["domain"].should be_nil
    end
    it "should set nested parameters" do
      described_class.evaluate_scryfile(:scryfile_contents => "namespace 'project' do\n  param 'domain'\nend")
      Scry["project"]["domain"].should be_nil
    end
    it "should set deeply nested parameters" do
      described_class.evaluate_scryfile(:scryfile_contents => valid_scryfile_string)
      Scry["project"]["web"]["hostname"].should be_nil
    end
    it "should set default values" do
      described_class.evaluate_scryfile(:scryfile_contents => valid_scryfile_string)
      Scry['project']['mail']['method'].should eq('sendmail')
    end
  end

  describe "param type" do
    before(:each) { Scry.init }
    it "should create a types validation hash" do
      described_class.evaluate_scryfile(:scryfile_contents => valid_scryfile_string)
      Scry.types['project']['domain'].should eq(String)
      Scry.types['project']['mail']['method'].should eq([String, FalseClass])
    end
  end

  describe "param description" do
    before(:each) { Scry.init }
    it "should create a description hash" do
      described_class.evaluate_scryfile(:scryfile_contents => valid_scryfile_string)
      Scry.descriptions['project']['domain'].should eq("Canonical domains name")
      Scry.descriptions['project']['mail']['method'].should eq("Mailer method")
    end
  end

  def fake_scryfile(name, contents)
    File.stub!(:exist?).with(name) { true }
    File.stub!(:read).with(name) { contents }
  end

  def valid_scryfile_string
    <<-EOT
    source '#{File.join(@fixture_path, 'dsl', 'scry.yml')}'
    source '#{File.join(@fixture_path, 'dsl', 'scry_override.yml')}'

    namespace 'project' do
      param 'domain', :required => true, :type => String, :description => "Canonical domains name"
      namespace 'web' do
        param 'hostname', :required => true, :type => String, :description => "Internal web hostname"
      end
      namespace 'mail' do
        param 'method', :default => 'sendmail', :type => [String, FalseClass], :description => "Mailer method"
      end
    end
    EOT
  end
end
