# typed: true
# frozen_string_literal: true

class WhatsappGroupAgent
  module MessageLoadingTools
    extend T::Sig
    extend T::Helpers

    requires_ancestor { WhatsappGroupAgent }

    extend ActiveSupport::Concern

    # == Tool ==

    LOAD_MESSAGES_BEFORE_TOOL = {
      name: "load_messages_before",
      description: "Scroll upward from a known anchor message.",
      parameters: {
        type: "object",
        properties: {
          anchor_message_id: {
            type: "string",
            description: "The message ID to scroll from.",
          },
          limit: {
            type: "integer",
            description: "Maximum number of messages to load.",
            minimum: 1,
            maximum: 50,
            default: 10,
          },
        },
        required: [ "anchor_message_id", "limit" ],
      },
    }

    LOAD_MESSAGES_AFTER_TOOL = {
      name: "load_messages_after",
      description: "Scroll downwards from a known anchor message.",
      parameters: {
        type: "object",
        properties: {
          anchor_message_id: {
            type: "string",
            description: "The message ID to scroll from.",
          },
          limit: {
            type: "integer",
            description: "Maximum number of messages to load.",
            minimum: 1,
            maximum: 50,
            default: 10,
          },
        },
        required: [ "anchor_message_id", "limit" ],
      },
    }

    SEARCH_MESSAGES_TOOL = {
      name: "search_messages",
      description: "Search for messages in the group.",
      parameters: {
        type: "object",
        properties: {
          any_keywords: {
            type: "array",
            items: {
              type: "string",
            },
            description: "Match if ANY of these keywords are present. Mutually exclusive with `all_keywords`.",
          },
          all_keywords: {
            type: "array",
            items: {
              type: "string",
            },
            description: "Match if ALL of these keywords are present. Mutually exclusive with `any_keywords`.",
          },
          any_participants: {
            type: "array",
            items: {
              type: "string",
            },
            description: "Matches if ANY participants (by LID, JID, or phone number) are present.",
          },
          date_range: {
            type: "object",
            properties: {
              from: {
                type: "string",
                description: "ISO-8601 range start date.",
              },
              to: {
                type: "string",
                description: "ISO-8601 range end date.",
              },
            },
            required: [ "from", "to" ],
            description:
              "The date range to search for messages in. Strongly consider " \
              "setting this value.",
          },
          limit: {
            type: "integer",
            description: "Maximum number of messages to load.",
            minimum: 1,
            maximum: 50,
            default: 10,
          },
          page: {
            type: "integer",
            description: "Page number to load.",
            minimum: 1,
            default: 1,
          },
        },
        required: [ "limit" ],
      },
    }

    MESSAGE_LOADING_TOOLS = [
      LOAD_MESSAGES_BEFORE_TOOL,
      LOAD_MESSAGES_AFTER_TOOL,
      SEARCH_MESSAGES_TOOL,
    ]

    # == Execution ==

    sig { params(anchor_message_id: String, limit: Integer).returns(String) }
    def load_messages_before(anchor_message_id:, limit: 10)
      group = group!
      load_group_messages do |group_messages|
        tag_logger do
          logger.info(
            "Loading messages before #{anchor_message_id} in group " \
              "#{group.jid}",
          )
        end
        anchor_message = group_messages
          .find_by!(whatsapp_id: anchor_message_id)
        previous_messages = anchor_message.previous_messages(limit:)
        previous_messages.reverse_each
      end
    end

    sig { params(anchor_message_id: String, limit: Integer).returns(String) }
    def load_messages_after(anchor_message_id:, limit: 10)
      group = group!
      load_group_messages do |group_messages|
        tag_logger do
          logger.info(
            "Loading messages after #{anchor_message_id} in group #{group.jid}",
          )
        end
        anchor_message = group_messages
          .find_by!(whatsapp_id: anchor_message_id)
        next_messages = anchor_message.next_messages(limit:)
        next_messages.each
      end
    end

    sig do
      params(
        any_keywords: T.nilable(T::Array[String]),
        all_keywords: T.nilable(T::Array[String]),
        any_participants: T.nilable(T::Array[String]),
        date_range: T.nilable({ from: String, to: String }),
        limit: Integer,
        page: Integer,
      ).returns(String)
    end
    def search_messages(
      any_keywords: nil,
      all_keywords: nil,
      any_participants: nil,
      date_range: nil,
      limit: 10,
      page: 1
    )
      group = group!
      all_keywords = normalized_values(all_keywords) if all_keywords
      any_keywords = normalized_values(any_keywords) if any_keywords
      any_participants = normalized_values(any_participants) if any_participants
      pagy = T.let(nil, T.nilable(Pagy))
      rendered_messages = load_group_messages do |group_messages|
        tag_logger do
          parameters = {
            any_keywords:,
            all_keywords:,
            any_participants:,
            date_range:,
          }.compact_blank
          logger.info(
            "Searching for messages in group #{group.jid} with options: " \
              "#{parameters.to_json}",
          )
        end

        # Early return if no filters to apply
        if [ any_keywords, all_keywords, any_participants, date_range ].all?(&:blank?)
          next [].each
        end

        # Build scope
        scope = group_messages.all
        if any_participants.present?
          scope = filter_by_participants(scope, participants: any_participants)
        end
        if date_range.present?
          from = Time.zone.parse(date_range.fetch(:from)).beginning_of_day
          to = Time.zone.parse(date_range.fetch(:to)).end_of_day
          scope = scope.where(timestamp: from..to)
        end
        if [ any_keywords, all_keywords ].any?(&:present?)
          scope = filter_by_keywords(scope, all_keywords:, any_keywords:)
        end

        pagy, messages = pagy(
          :countless,
          scope,
          limit:,
          page:,
          request: {
            params: {},
          },
        )
        messages.each
      end
      if pagy.present?
        <<~EOF
          ### RESULT METADATA
          ```json
          #{pagy.data_hash(data_keys: [ :page, :next, :count, :pages ])}
          ```

          ---

          #{rendered_messages}
        EOF
      else
        rendered_messages
      end
    end

    private

    # == Helpers ==

    sig { params(values: T::Array[String]).returns(T::Array[String]) }
    def normalized_values(values)
      values.filter_map do |value|
        value.strip.presence
      end
    end

    sig do
      params(keywords: T::Array[String], operator: String)
        .returns(T.nilable(String))
    end
    def build_query(keywords, operator:)
      keywords
        .map { |keyword| quote_keyword(keyword) }
        .join(" #{operator} ")
    end

    sig { params(keyword: String).returns(String) }
    def quote_keyword(keyword)
      escaped = keyword.gsub("'", "''")
      "'#{escaped}'"
    end

    sig do
      params(
        scope: WhatsappMessage::PrivateAssociationRelation,
        all_keywords: T.nilable(T::Array[String]),
        any_keywords: T.nilable(T::Array[String]),
      ).returns(WhatsappMessage::PrivateAssociationRelation)
    end
    def filter_by_keywords(scope, all_keywords: nil, any_keywords: nil)
      if all_keywords.present? && any_keywords.present?
        raise "`all_keywords` and `any_keywords` are mutually exclusive."
      end

      if all_keywords.present?
        if (query = build_query(all_keywords, operator: "&"))
          scope = scope.search(query)
        end
      elsif any_keywords.present?
        if (query = build_query(any_keywords, operator: "|"))
          scope = scope.search(query)
        end
      end
      scope
    end

    sig do
      params(
        scope: WhatsappMessage::PrivateAssociationRelation,
        participants: T::Array[String],
      ).returns(WhatsappMessage::PrivateAssociationRelation)
    end
    def filter_by_participants(scope, participants:)
      lids = T.let([], T::Array[String])
      jids = T.let([], T::Array[String])
      phone_numbers = T.let([], T::Array[String])
      participants.each do |participant|
        if participant.end_with?("@lid")
          lids << participant
        elsif participant.end_with?("@s.whatsapp.net")
          jids << participant
        else
          phone = Phonelib.parse(participant)
          phone_numbers << phone.sanitized
        end
      end

      # Early return if no participants to filter by
      if [ lids, jids, phone_numbers ].all?(&:empty?)
        return scope
      end

      participant_ids = WhatsappUser.where(lid: lids)
        .or(WhatsappUser.where(phone_number: phone_numbers))
        .or(WhatsappUser.where(phone_number_jid: jids))
        .distinct
        .select(:id)
      sent_by_participants = WhatsappMessage.where(sender_id: participant_ids)
      mentions_include_participants = WhatsappMessage.where(
        id: WhatsappMessageMention
          .where(mentioned_user_id: participant_ids)
          .select(:message_id),
      )
      quoting_participants = WhatsappMessage.where(
        quoted_message_id: sent_by_participants.select(:id),
      )
      scope.and(
        sent_by_participants
        .or(mentions_include_participants)
        .or(quoting_participants),
      )
    end

    sig do
      params(
        apply_filter: T.proc.params(
          group_messages: WhatsappMessage::PrivateCollectionProxy,
        ).returns(T::Enumerable[WhatsappMessage]),
      ).returns(String)
    end
    def load_group_messages(&apply_filter)
      group = group!
      begin
        messages = yield(group.messages)
        formatted_messages = T.let([], T::Array[String])
        messages.each_with_index do |message, index|
          heading = "## MESSAGE #{index + 1}:"
          content = render_to_string(
            partial: "agents/whatsapp_group/message",
            locals: {
              message:,
            },
          )
          formatted_messages << [ heading, content ].join("\n")
        end
        formatted_messages.join("\n\n")
      rescue => error
        tag_logger do
          logger.error(
            "Failed to load messages in group #{group.jid}: #{error}",
          )
        end
        JSON.pretty_generate({ error: error.message })
      end
    end
  end
end
