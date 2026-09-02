# frozen_string_literal: true

require "ruby_lsp/addon"

module RubyLsp
  module SourceDocumentLinks
    # Teaches ruby-lsp's DocumentLink listener to resolve `source://<relative>:<line>`
    # comments to absolute paths in the workspace, so Tapioca-generated RBIs can
    # link back to source files inside this Rails app (not just gems).
    class Addon < ::RubyLsp::Addon
      class << self
        attr_accessor :workspace_path #: String?
        attr_accessor :index #: RubyIndexer::Index?
      end

      #: (GlobalState, Thread::Queue) -> void
      def activate(global_state, _outgoing_queue)
        self.class.workspace_path = global_state.workspace_path
        self.class.index = global_state.index
        RubyLsp::Listeners::DocumentLink.prepend(Extension)
      end

      #: (RubyLsp::ResponseBuilders::CollectionResponseBuilder[untyped], URI::Generic, RubyLsp::NodeContext, Prism::Dispatcher) -> void
      def create_definition_listener(response_builder, _uri, _node_context, dispatcher)
        DefinitionListener.new(response_builder, dispatcher)
      end

      #: -> void
      def deactivate; end

      #: -> String
      def name
        "Source Document Links"
      end

      #: -> String
      def version
        "0.1.0"
      end
    end

    class DefinitionListener
      #: (RubyLsp::ResponseBuilders::CollectionResponseBuilder[untyped], Prism::Dispatcher) -> void
      def initialize(response_builder, dispatcher)
        @response_builder = response_builder
        dispatcher.register(self, :on_call_node_enter)
      end

      #: (Prism::CallNode) -> void
      def on_call_node_enter(node)
        receiver = node.receiver
        return unless receiver

        receiver_name = RubyIndexer::Index.constant_name(receiver)
        return unless receiver_name && node.name.match?(/\A[A-Z]/)

        entries = Addon.index&.[]("#{receiver_name}::#{node.name}")
        return unless entries

        links = entries.grep(RubyIndexer::Entry::Namespace).map do |entry|
          location = entry.location
          RubyLsp::Interface::Location.new(
            uri: entry.uri.to_s,
            range: RubyLsp::Interface::Range.new(
              start: RubyLsp::Interface::Position.new(
                line: location.start_line - 1,
                character: location.start_column,
              ),
              end: RubyLsp::Interface::Position.new(
                line: location.end_line - 1,
                character: location.end_column,
              ),
            ),
          )
        end
        return if links.empty?

        @response_builder.response.clear
        links.each { |link| @response_builder << link }
      end
    end

    module Extension
      SOURCE_URI_REGEX = %r{source://(?<path>[^\s:]+):(?<line>\d+)}

      #: (Prism::Node) -> void
      def extract_document_link(node)
        comment = @lines_to_comments[node.location.start_line - 1] ||
          @sig_comments[node.location.start_line - 1]

        if comment && (match = comment.location.slice.match(SOURCE_URI_REGEX))
          workspace = Addon.workspace_path
          if workspace
            file_path = File.join(workspace, match[:path])
            line_number = match[:line]

            @response_builder << RubyLsp::Interface::DocumentLink.new(
              range: range_from_location(comment.location),
              target: "file://#{file_path}##{line_number}",
              tooltip: "Jump to #{file_path}##{line_number}",
            )
            return
          end
        end

        super
      end
    end
  end
end
