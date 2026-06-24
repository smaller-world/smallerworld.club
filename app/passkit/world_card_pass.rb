# typed: strict
# frozen_string_literal: true

module Passkit
  class WorldCardPass < ApplicationPass
    include ActionView::Helpers::TagHelper

    extend T::Sig

    # == Configuration ==

    sig { override.params(path: Pathname).void }
    def add_other_files(path)
      world_icon = @world.icon_attachment or return
      [ :logo, :logo_2x, :icon, :icon_2x, :icon_3x ].each do |key|
        variant = :"passkit_#{key}"
        filename = "#{key.to_s.tr("_", "@")}.png"
        world_icon.variant(variant).processed.image.open do |file|
          FileUtils.mv(file.path, path.join(filename))
        end
      end
    end

    # == Initialization ==

    sig { override.params(card: WorldCard).void }
    def initialize(card)
      @card = card
      @world = T.let(card.world!, World)
      @cardholder = T.let(card.cardholder, T.nilable(User))
      super(card)
    end

    # == Attributes ==

    sig { override.returns(Symbol) }
    def pass_type = :eventTicket

    sig { override.returns(String) }
    def background_color = "rgb(255, 255, 255)"

    sig { override.returns(String) }
    def foreground_color = "rgb(12, 12, 9)"

    sig { override.returns(String) }
    def label_color = "rgb(124, 124, 103)"

    sig { override.returns(String) }
    def organization_name = @world.name

    sig { override.returns(String) }
    def logo_text = @world.name

    sig { override.returns(T::Boolean) }
    def suppress_strip_shine = false # rubocop:disable Naming/PredicateMethod

    sig { override.returns(String) }
    def description
      if @cardholder
        "you're a part of #{@world.name}"
      else
        "you're invited to #{@world.name}"
      end
    end

    sig { override.returns(T::Array[T::Hash[Symbol, String]]) }
    def header_fields
      fields = []
      if (value = @world.posts.order(created_at: :desc).pick(:created_at))
        fields << {
          key: "last_posted_at",
          label: "last posted",
          value: value,
          "dateStyle" => "PKDateStyleMedium",
          "timeStyle" => "PKDateStyleNone",
          "textAlignment" => "PKTextAlignmentRight",
        }
      end
      fields
    end

    sig { override.returns(T::Array[T::Hash[Symbol, String]]) }
    def secondary_fields
      field = if @cardholder
        {
          key: "cardholder",
          label: "cardholder",
          value: @cardholder.name,
        }
      else
        {
          key: "installation_instructions",
          label: "install the smaller world app 👇 to get started",
          value: "🔗 #{app_hostname}",
        }
      end
      [ field ]
    end

    sig { override.returns(T::Array[T::Hash[Symbol, String]]) }
    def auxiliary_fields
      fields = []
      fields << {
        key: "issued_at",
        label: @cardholder ? "cardholder since" : "invitation issued",
        value: @card.created_at.iso8601,
        "dateStyle" => "PKDateStyleMedium",
        "timeStyle" => "PKDateStyleNone",
      }
      if (post = @world.posts.chronological.last)
        fields << {
          key: "last_post_teaser",
          label: "last post",
          value: post.card_snippet,
        }
      end
      fields
    end

    sig { override.returns(T::Array[T::Hash[Symbol, String]]) }
    def back_fields
      fields = []
      if (post = @world.posts.chronological.last)
        field = {
          key: "last_post",
          label: "✍️ last post in #{@world.name}",
          value: post.snippet,
        }
        if @card.device&.push_token? && !@card.discarded?
          field["changeMessage"] = "%@"
        end
        fields << field
      end
      fields << {
        key: "contact",
        label: "🛟 contact smaller world",
        value: "team@smallerworld.club",
      }
      if @card.device
        world_url = shortlinked_url_helpers.world_url(@world)
        fields << {
          key: "world_link",
          label: "🔗 world link",
          value: world_url,
          "attributedValue" => tag.a(
            "open #{@world.name} in the app".html_safe, # rubocop:disable Rails/OutputSafety
            href: world_url,
          ),
          "dataDetectorTypes" => [ "PKDataDetectorTypeLink" ],
        }
      end
      fields << {
        key: "card_id",
        label: "🪪 card id (for developers)",
        value: @card.short_id,
      }
      fields
    end

    sig { override.returns(T::Array[T::Hash[Symbol, String]]) }
    def barcodes
      card_id = @card.short_id
      [
        {
          messageEncoding: "utf-8",
          format: "PKBarcodeFormatPDF417",
          message: card_id,
          altText: Rails.env.production? ? card_id : "#{card_id} (dev)",
        },
      ]
    end

    sig { override.returns(T.nilable(String)) }
    def relevant_date
      @card.relevant_date&.iso8601
    end

    sig { override.returns(T::Boolean) }
    def voided # rubocop:disable Naming/PredicateMethod
      @card.discarded?
    end

    sig { override.returns(T::Array[String]) }
    def associated_store_identifiers
      [ Smallerworld.application.ios_store_identifier ]
    end

    sig { override.returns(T.nilable(String)) }
    def app_launch_url
      shortlinked_url_helpers.world_url(@world)
    end

    private

    # == Helpers ==

    sig { returns(UrlHelpers) }
    def shortlinked_url_helpers
      Smallerworld.application.shortlinked_url_helpers
    end

    sig { returns(String) }
    def app_hostname
      @app_hostname ||= T.let(
        begin
          uri = Addressable::URI.parse(shortlinked_url_helpers.root_url)
          uri.hostname
        end,
        T.nilable(String),
      )
    end
  end
end
