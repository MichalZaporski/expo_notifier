# typed: true

module Shale
  module Schema; end

  class Mapper
    class << self
      sig { params(block: T.proc.bind(Shale::Mapping::Dict).void).void }
      def json(&block); end

      sig { params(block: T.proc.bind(Shale::Mapping::Dict).void).void }
      def hsh(&block); end

      sig { params(block: T.proc.bind(Shale::Mapping::Dict).void).void }
      def yaml(&block); end

      sig { params(block: T.proc.bind(Shale::Mapping::Dict).void).void }
      def toml(&block); end

      sig { params(block: T.proc.bind(Shale::Mapping::Dict).void).void }
      def csv(&block); end

      sig { params(block: T.proc.bind(Shale::Mapping::Xml).void).void }
      def xml(&block); end
    end
  end
end
