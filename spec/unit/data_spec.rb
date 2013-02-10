require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe Scry::DataNode do
  describe "init" do
    it "should be a kind of Hash" do
      Scry::DataNode.new.should be_a_kind_of(Hash)
    end

    it "should be a kind of Scry::DataNode" do
      Scry::DataNode.new.should be_a_kind_of(Scry::DataNode)
    end
  end

  describe "insert" do
    it "should convert new hash items to Scry::DataNode" do
      d = Scry::DataNode.new
      d['k'] = { 'a' => 'b' }
      d['k'].should be_a_kind_of(Scry::DataNode)
    end
  end

  describe "from_hash" do
    it "should recursively convert incoming Hash's to Scry::DataNode" do
      d = Scry::DataNode.from_hash({'foo'=>'bar','container'=>{'a'=>'b'}})
      d.should be_a_kind_of(Scry::DataNode)
      d['container'].should be_a_kind_of(Scry::DataNode)
    end
  end
end
