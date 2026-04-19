# typed: true

module PhlexIcons
  extend Phlex::Kit

  class Icon < Phlex::SVG; end

  sig { params(name: String, options: T.untyped).void }
  def Icon(name, **options); end # rubocop:disable Naming/MethodName

  sig { params(block: T.proc.params(config: T.untyped).void).void }
  def self.configure(&block); end
end
