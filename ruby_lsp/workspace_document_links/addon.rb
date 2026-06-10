# frozen_string_literal: true

require "ruby_lsp/addon"

module RubyLsp
  module WorkspaceDocumentLinks
    # Teaches ruby-lsp's DocumentLink listener to resolve `workspace://<relative>:<line>`
    # comments to absolute paths in the workspace, so Tapioca-generated RBIs can
    # link back to source files inside this Rails app (not just gems).
    class Addon < ::RubyLsp::Addon
      class << self
        attr_accessor :workspace_path #: String?
      end

      #: (GlobalState, Thread::Queue) -> void
      def activate(global_state, _outgoing_queue)
        self.class.workspace_path = global_state.workspace_path
        RubyLsp::Listeners::DocumentLink.prepend(Extension)
      end

      #: -> void
      def deactivate; end

      #: -> String
      def name
        "Workspace Document Links"
      end

      #: -> String
      def version
        "0.1.0"
      end
    end

    module Extension
      WORKSPACE_URI_REGEX = %r{workspace://(?<path>[^\s:]+):(?<line>\d+)}

      #: (Prism::Node) -> void
      def extract_document_link(node)
        comment = @lines_to_comments[node.location.start_line - 1] ||
          @sig_comments[node.location.start_line - 1]

        if comment && (match = comment.location.slice.match(WORKSPACE_URI_REGEX))
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
