# typed: strict
# frozen_string_literal: true

class Components::Layout < Components::Base
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::JavaScriptIncludeTag
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::AssetPath
  include Phlex::Rails::Helpers::ActionCableMetaTag

  sig do
    params(
      site_title: T.nilable(String),
      page_title: T.nilable(T.any(String, T::Array[String])),
      body_class: T.nilable(String),
      attributes: T.untyped,
    ).void
  end
  def initialize(
    site_title: nil,
    page_title: nil,
    body_class: nil,
    **attributes
  )
    super(**attributes)
    @site_title = site_title
    @page_title = T.let(
      if page_title.is_a?(Array)
        page_title.reverse.compact.join(" | ")
      else
        page_title
      end,
      T.nilable(String),
    )
    @body_class = body_class
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    body = capture(&content)

    doctype

    root_element(:html) do
      head do
        if (text = title_text)
          title { text }
        end

        meta(charset: "UTF-8")
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        if (name = Rails.configuration.x.site_name)
          meta(name: "application-name", content: name)
        end
        meta(name: "mobile-web-app-capable", content: "yes")

        csrf_meta_tags
        csp_meta_tag
        action_cable_meta_tag

        meta(name: "env", content: Rails.env)

        # == Favicons
        link(rel: "shortcut icon", href: "/favicon.ico")
        link(rel: "icon", href: "/favicon-96x96.png", type: "image/png", sizes: "96x96")
        link(rel: "icon", href: "/favicon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", sizes: "180x180", href: "/apple-touch-icon.png")
        link(rel: "manifest", href: "/site.webmanifest")

        # == Fonts
        link(rel: "preconnect", href: "https://fonts.googleapis.com")
        link(rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: true)
        link(href: "https://fonts.googleapis.com/css2?family=Quicksand:wght@300..700&display=swap", rel: "stylesheet")
        # link(rel: "stylesheet", href: "https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap")

        # == Assets
        stylesheet_link_tag("application", "data-turbo-track": "reload")
        javascript_include_tag("application", "data-turbo-track": "reload", type: "module")

        # == OpenGraph
        if (description = Rails.configuration.x.site_description)
          meta(name: "description", content: description)
        end
        render_og_tags
        render_twitter_tags

        # == Head
        @head&.call
      end

      body(class: [ "flex min-h-dvh flex-col", @body_class ]) do
        Components::Header()
        render_flash(class: "m-4 self-center")
        raw(body) # rubocop:disable Rails/OutputSafety
      end
    end
  end

  # == Interface ==

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def page_container(**attributes, &content)
    div(**mix({ class: "page_container" }, **attributes), &content)
  end

  sig { params(content: T.proc.void).void }
  def with_head(&content)
    @head = T.let(content, T.nilable(T.proc.void))
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(String)) }
  def title_text
    @site_title ||
      [ @page_title, Rails.configuration.x.site_name ]
        .compact.join(" | ").presence
  end

  sig { returns(T.nilable(String)) }
  def root_domain
    url_options[:host]
  end

  sig { void }
  def render_og_tags
    meta(property: "og:type", content: "website")
    meta(property: "og:url", content: root_url)
    meta(property: "og:title", content: title_text)
    if (description = Rails.configuration.x.site_description)
      meta(property: "og:description", content: description)
    end
    meta(property: "og:image", content: asset_path("/banner.png"))
  end

  sig { void }
  def render_twitter_tags
    meta(name: "twitter:card", content: "summary_large_image")
    if (domain = root_domain)
      meta(property: "twitter:domain", content: domain)
    end
    meta(property: "twitter:url", content: root_url)
    meta(name: "twitter:title", content: title_text)
    if (description = Rails.configuration.x.site_description)
      meta(name: "twitter:description", content: description)
    end
    meta(name: "twitter:image", content: "/banner.png")
  end

  sig { params(attributes: T.untyped).void }
  def render_flash(**attributes)
    message = flash[:notice] || flash[:alert] or return
    Components::Card(
      size: :sm,
      **mix(
        {
          class: class_names(
            "flash card",
            { "flash-alert": flash.key?(:alert) },
          ),
        },
        **attributes,
      ),
    ) do |card|
      card.content(class: "font-medium") do
        message
      end
    end
  end
end
