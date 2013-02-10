require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe Scry do
  describe "init" do
    before(:each) { Scry.init }

    it "should require a Scryfile" do
      Scry.init.scryfile.should eq(ENV['SCRYFILE'])
    end

    it "should raise an error if the Scryfile can't be found" do
      ENV['SCRYFILE'] = nil
      expect{Scry.init}.to raise_error(Scry::ScryfileNotFound)
    end

  end

  describe "data access" do
    before(:each) { Scry.init }

    it "should be able to access keys like a hash" do
      cfg = Scry.init(:data => {'key'=>'value'})
      cfg['key'].should be_a_kind_of(String)
      cfg['key'].should eq('value')
    end

    it "should be able to access nested keys like a hash" do
      cfg = Scry.init(:data => {'container'=>{'key'=>'value'}})
      cfg['container']['key'].should be_a_kind_of(String)
      cfg['container']['key'].should eq('value')
    end

    it "should allow access to keys using fetch" do
      cfg = Scry.init(:data => {'foo'=>'bar', 'container'=>{'key'=>'value'}})
      cfg.fetch('foo').should eq('bar')
      cfg.fetch('container', 'key').should eq('value')
    end

    it "should raise a ConfigKeyNotFound when a key can't be found" do
      cfg = Scry.init(:data => {'foo'=>'bar', 'container'=>{'key'=>'value'}})
      expect{cfg['not_found']}.to raise_error(Scry::ConfigKeyNotFound)
      expect{cfg['container']['not_found']}.to raise_error(Scry::ConfigKeyNotFound)
    end

  end

  describe "configuration sources" do
    before(:each) { Scry.init }

    it "should not complain if a sourcefile is missing" do
      Scry.init(:scryfile_contents => valid_scryfile_string)
    end

    it "should merge files correctly" do
      Scry.init(:scryfile_contents => valid_scryfile_string)
      Scry['project']['domain'].should eq('www.example.com')
      Scry['project']['web']['hostname'].should eq('www.example.int')
    end

    it "should merge files correctly and respect defaults" do
      Scry.init(:scryfile_contents => valid_scryfile_string)
      Scry['project']['mail']['method'].should eq('sendmail')
    end

  end

  describe "detect configuration problems" do
    before(:each) { Scry.init }

    it "should raise an error if a defined parameter exists without a value" do
      expect { Scry.init(:scryfile_contents => missing_param_scryfile_string) }.to raise_error(Scry::MissingRequiredParameter)
    end

    it "should raise an error if a nested defined parameter exists without a value" do
      expect { Scry.init(:scryfile_contents => nested_missing_param_scryfile_string) }.to raise_error(Scry::MissingRequiredParameter)
    end

    it "should raise an error if a defined parameter exists with a well formed error message" do
      errmsg = 
/ERROR!!!! Missing required parameter in Scry configuration sources!
Parameter:   Scry\['missing_item'\]
Description: Missing
Configured Scry sources:
1\. .*scry\/scry.yml
2\. .*scry\/missing.yml
3\. .*scry\/scry_override.yml

# BEGIN - Example YAML representation of missing parameter

missing_item: your configuration goes here

# END/
      expect { Scry.init(:scryfile_contents => missing_param_scryfile_string) }.to raise_error(Scry::MissingRequiredParameter, errmsg)
    end

    it "should raise an error if a parameter has an invalid type" do
      expect { Scry.init(:scryfile_contents => bad_type_scryfile_string) }.to raise_error(Scry::ParameterTypeMismatch)
    end

    it "should raise an error if a nested parameter has an invalid type" do
      expect { Scry.init(:scryfile_contents => nested_bad_type_scryfile_string) }.to raise_error(Scry::ParameterTypeMismatch)
    end

    it "should raise an error if a parameter has an invalid type with a well formed error message" do
      errmsg = 
/ERROR!!!! A parameter in the Scry configuration has an invalid type!
Parameter:   Scry\['hostname'\]
Value:       a string
Found type:  String
Expected:    Array
Description: Why is this an Array
Configured Scry sources:
1\. .*scry\/scry.yml
2\. .*scry\/missing.yml
3\. .*scry\/scry_override.yml/
      expect { Scry.init(:scryfile_contents => bad_type_scryfile_string) }.to raise_error(Scry::ParameterTypeMismatch, errmsg)
    end

  end

  def scryfile_sources_string
    <<-EOT
    source '#{File.join(@fixture_path, 'scry', 'scry.yml')}'
    source '#{File.join(@fixture_path, 'scry', 'missing.yml')}'
    source '#{File.join(@fixture_path, 'scry', 'scry_override.yml')}'
    EOT
  end

  def valid_scryfile_string
    <<-EOT
    #{scryfile_sources_string}
    namespace 'project' do
      param 'domain', :type => String, :description => "Canonical domains name"
      namespace 'web' do
        param 'hostname', :type => String, :description => "Internal web hostname"
      end
      namespace 'mail' do
        param 'method', :default => 'sendmail', :type => [String, FalseClass], :description => "Mailer method"
      end
    end
    EOT
  end

  def missing_param_scryfile_string
    <<-EOT
    #{scryfile_sources_string}
    param 'missing_item', :type => Array, :description => "Missing"
    EOT
  end

  def nested_missing_param_scryfile_string
    <<-EOT
    #{scryfile_sources_string}
    namespace 'project' do
      namespace 'one' do
        param 'foo', :default => 'someting'
      end
      namespace 'two' do
        param 'foo', :default => 'someting'
      end
      namespace 'web' do
        param 'missing_item', :type => String, :description => "Missing"
      end
    end
    EOT
  end

  def bad_type_scryfile_string
    <<-EOT
    #{scryfile_sources_string}
    param 'hostname', :default => "a string", :type => Array, :description => "Why is this an Array"
    EOT
  end

  def nested_bad_type_scryfile_string
    <<-EOT
    #{scryfile_sources_string}
    namespace 'project' do
      namespace 'one' do
        param 'foo', :default => 'someting'
      end
      namespace 'two' do
        param 'bar', :default => 'someting'
      end
      namespace 'web' do
        param 'hostname', :type => Array, :description => "Why is this an Array"
      end
    end
    EOT
  end

end
