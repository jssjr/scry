module Scry
  class Printer
    class << self
      def to_s
        self.print
      end

      def print
        puts rformat_node(Scry.data, Scry.types, Scry.descriptions)
      end

      private

      def rformat_node(node_data, node_types, node_descriptions, stack = [])
        if node_data.is_a?(Scry::DataNode)
          puts "DataNode node"
        end
      end
    end
  end
end
