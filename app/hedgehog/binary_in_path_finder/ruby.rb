module Hedgehog
  module BinaryInPathFinder
    class Ruby
      def call(binary)
        Hedgehog::Environment::Path
          .binaries
          .find { |path| path.match(/\/#{binary}$/) }
      end
    end
  end
end
