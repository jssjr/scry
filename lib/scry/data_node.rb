module Scry
  class DataNode < Hash
    attr_accessor :required, :type

    def [](k)
      unless self.has_key?(k)
        nil
        #raise ConfigKeyNotFound, "Unable to locate config key: #{k}"
      end
      super(k)
    end

    def []=(k,v)
      if v.is_a?(Hash)
        super(k,DataNode.from_hash(v))
      else
        super(k,v)
      end
    end

    def self.from_hash(hash)
      r = DataNode.new
      hash.each do |k,v|
        if v.is_a?(Hash)
          r[k] = DataNode.from_hash(v)
        else
          r[k] = v
        end
      end
      r
    end
  end
end
