# typed: strict
# frozen_string_literal: true

class Components::AppLayout < Components::Base
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::JavaScriptIncludeTag
  include Phlex::Rails::Helpers::AssetPath
  include Phlex::Rails::Helpers::ActionCableMetaTag
  include DeleteFrom

  # == Initialization ==

  sig do
    params(
      page_title: T.nilable(T.any(String, T::Array[String])),
      title: T.nilable(String),
      force_header: T.nilable(TrueClass),
      disable_cache: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    page_title: nil,
    title: nil,
    force_header: nil,
    disable_cache: false,
    **attributes
  )
    super(**attributes)
    @page_title = T.let(
      if page_title.is_a?(Array)
        page_title.reverse.compact.join(" | ")
      else
        page_title
      end,
      T.nilable(String),
    )
    @title = title
    @force_header = force_header
    @disable_cache = disable_cache
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    attributes = @attributes
    body_attributes = delete_from(attributes, :class, :data)

    content_html = capture(&content)

    doctype

    html(**mix(
      { data: { hotwire_native_platform: } },
      attributes,
    )) do
      head do
        if (site_title = self.site_title)
          title { site_title }
        end

        meta(charset: "UTF-8")
        meta(name: "viewport", content: "width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "application-name", content: SmallerWorld.application.site_name)
        meta(name: "mobile-web-app-capable", content: "yes")
        meta(name: "view-transition", content: "same-origin")

        csrf_meta_tags
        csp_meta_tag
        action_cable_meta_tag

        meta(name: "env", content: Rails.env)

        # == Turbo
        meta(name: "turbo-refresh-scroll", content: "preserve")
        if @disable_cache
          meta(name: "turbo-cache-control", content: "no-cache")
        end

        # == Favicons
        link(rel: "shortcut icon", href: "/favicon.ico")
        link(rel: "icon", href: "/favicon-96x96.png", type: "image/png", sizes: "96x96")
        link(rel: "apple-touch-icon", sizes: "180x180", href: "/apple-touch-icon.png")

        # == Fonts
        link(rel: "preconnect", href: "https://fonts.googleapis.com")
        link(rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: true)
        link(
          rel: "stylesheet",
          href: "https://fonts.googleapis.com/css2?family=Figtree:wght@300..900&family=Manrope:wght@200..800&family=Single+Day&display=swap",
        )

        # == Assets
        stylesheet_link_tag("application", "data-turbo-track": "reload")
        stylesheet_link_tag("application.bundle", "data-turbo-track": "reload")
        javascript_include_tag("application", "data-turbo-track": "reload", type: "module")

        # == Meta & OpenGraphh
        if (description = Rails.configuration.x.site.description)
          meta(name: "description", content: description)
        end
        og_tags
        twitter_tags

        # == Head
        @head&.call
      end

      body(**mix(
        {
          class: "app-layout",
          data: {
            controller: [
              "page-load-bridge",
              "notification-permission-bridge",
              "notifications-status",
              "page-visibility",
            ],
            notifications_status_push_token_saved_value: Current.device&.push_token?,
            action: [
              "notification-permission-bridge:retrieved->notifications-status#update",
              "page-visibility:visible->notification-permission-bridge#get",
            ],
          },
        },
        body_attributes,
      )) do
        if @force_header || !hotwire_native_app?
          Components::AppHeader()
        end
        Components::AppFlashes()
        raw(content_html) # rubocop:disable Rails/OutputSafety
        confetti_canvas
        logs_container
        toasts_container

        if (current_user = Current.user)
          # Auto-update user time zone
          Components::AccountTimeZoneForm(current_user:)
        end
      end
    end
  end

  # == Interface ==

  sig { params(element: Symbol, attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def page_container(element: :main, **attributes, &content)
    public_send(element, **mix({ class: "page-container" }, **attributes), &content)
  end

  sig { params(content: T.proc.void).void }
  def with_head(&content)
    @head = T.let(content, T.nilable(T.proc.void))
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(String)) }
  def root_domain
    url_options[:host]
  end

  sig { returns(T.nilable(String)) }
  def site_title
    return @site_title if defined?(@site_title)

    @site_title ||= T.let(
      @title ||
        if hotwire_native_app?
          @page_title
        else
          [ @page_title, SmallerWorld.application.site_name ]
            .compact
            .join(" | ")
        end,
      T.nilable(String),
    )
  end

  sig { void }
  def og_tags
    meta(property: "og:type", content: "website")
    meta(property: "og:url", content: root_url)
    if @page_title
      meta(property: "og:title", content: @page_title)
    end
    if (description = Rails.configuration.x.site.description)
      meta(property: "og:description", content: description)
    end
    meta(property: "og:image", content: asset_path("/banner.png"))
  end

  sig { void }
  def twitter_tags
    meta(name: "twitter:card", content: "summary_large_image")
    if (domain = root_domain)
      meta(property: "twitter:domain", content: domain)
    end
    meta(property: "twitter:url", content: root_url)
    if @page_title
      meta(name: "twitter:title", content: @page_title)
    end
    if (description = Rails.configuration.x.site.description)
      meta(name: "twitter:description", content: description)
    end
    meta(name: "twitter:image", content: "/banner.png")
  end

  sig { void }
  def confetti_canvas
    canvas(
      id: Rails.configuration.x.confetti_canvas_id,
      class: "fixed inset-0 pointer-events-none z-50",
      data: {
        turbo_permanent: true,
      },
    )
  end

  sig { void }
  def logs_container
    div(id: "logs", hidden: true)
  end

  sig { void }
  def toasts_container
    div(id: "toasts") do
      div(data: {
        turbo_permanent: true,
        controller: "toaster",
        action: "toast@document->toaster#toast",
      })
      # if (message = flash[:notice])
      #   Components::StreamedToast(message:, type: :info)
      # end
      # if (message = flash[:alert])
      #   Components::StreamedToast(message:, type: :warning)
      # end
    end
  end
end
