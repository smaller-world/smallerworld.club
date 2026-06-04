# typed: true
# frozen_string_literal: true

class Passes::WorldCard < Passkit::BasePass
  include ActionView::Helpers::TagHelper
  include Shortlinking

  extend T::Sig

  # == Configuration ==

  def pass_path = Rails.root.join("app/assets/passes/#{folder_name}")

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
    @cardholder = T.let(card.cardholder, T.nilable(User))
    @world = T.let(card.world!, World)
    super(card)
  end

  # == Attributes ==

  def pass_type = :eventTicket
  def background_color = "rgb(255, 255, 255)"
  def foreground_color = "rgb(12, 12, 9)"
  def label_color = "rgb(124, 124, 103)"
  def organization_name = @world.name
  def logo_text = @world.name
  def suppress_strip_shine = false # rubocop:disable Naming/PredicateMethod

  def description
    if @cardholder
      "you're a part of #{@world.name}"
    else
      "you're invited to #{@world.name}"
    end
  end

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

  def secondary_fields
    field = if @cardholder
      {
        key: "cardholder",
        label: "cardholder",
        value: @cardholder.name.upcase,
      }
    else
      {
        key: "installation_instructions",
        label: "install the smaller world app 👇 to get started",
        value: "🔗 app.smallerworld.club",
      }
    end
    [ field ]
  end

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
  end

  def back_fields
    receives_app_notifications = cardholder_receives_app_notifications?
    fields = []
    if (post = @world.posts.chronological.last)
      field = {
        key: "last_post",
        label: "✍️ last post in #{@world.name}",
        value: post.snippet,
      }
      unless receives_app_notifications
        field["changeMessage"] = "%@"
      end
      fields << field
    end
    fields << {
      key: "contact",
      label: "🛟 contact smaller world",
      value: "team@smallerworld.club",
    }
    if receives_app_notifications
      world_url = shortlinked.world_url(@world)
      fields << {
        key: "world_link",
        label: "🔗 world link",
        value: world_url,
        "attributedValue" => tag.a(
          "open #{@world.name} in the app",
          href: world_url,
        ),
        "dataDetectorTypes" => [ "PKDataDetectorTypeLink" ],
      }
    end
    fields << {
      key: "card_id",
      label: "🪪 card id (for developers)",
      value: @card.id,
    }
    fields
  end

  def barcodes
    card_id = ShortUUID.shorten(@card.id)
    [
      {
        messageEncoding: "utf-8",
        format: "PKBarcodeFormatPDF417",
        message: card_id,
        altText: card_id,
      },
    ]
  end

  def relevant_date
    @card.created_at.iso8601
  end

  private

  # == Helpers ==

  sig { override.returns(T::Hash[Symbol, String]) }
  def url_options
    Rails.configuration.action_mailer.default_url_options
  end

  sig { returns(T::Boolean) }
  def cardholder_receives_app_notifications?
    if (cardholder = @cardholder)
      cardholder.devices.exists?(
        platform: :apple,
        push_token: @card.pass_devices.select(:push_token),
      )
    else
      false
    end
  end
end
