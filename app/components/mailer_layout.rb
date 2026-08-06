# typed: strict
# frozen_string_literal: true

class Components::MailerLayout < Components::Base
  include DeleteFrom

  # == Helpers ==

  include Phlex::Rails::Helpers::StyleSheetLinkTag

  # # == Initialization ==

  # sig { params(title: String, attributes: T.untyped).void }
  # def initialize(title:, **attributes)
  #   super(**attributes)
  #   @title = title
  # end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    attributes = @attributes
    body_attributes = delete_from(attributes, :class)

    doctype

    html(dir: "ltr", lang: "en", **attributes) do
      head do
        meta(http_equiv: safe("Content-Type"), content: "text/html; charset=utf-8")
        meta(name: "x-apple-disable-message-reformatting")
        # title { @title }

        # == Fonts
        link(
          rel: "stylesheet",
          href: "https://fonts.googleapis.com/css2?family=Figtree:wght@300..900&family=Manrope:wght@200..800&display=swap",
        )

        # == Stylesheets (inlined with Premailer)
        stylesheet_link_tag("mailer")
      end
    end

    body(**body_attributes, &content)
  end

  # == Interface ==

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def email_container(**attributes, &content)
    table(
      id: "bodyTable",
      width: "100%",
      border: 0,
      cellspacing: 0,
      cellpadding: 0,
      role: "presentation",
      align: "center",
    ) do
      tbody do
        tr do
          td do
            table(
              align: "center",
              width: "100%",
              border: 0,
              cellspacing: 0,
              cellpadding: 0,
              role: "presentation",
              class: "max-w-lg ml-auto mr-auto",
            ) do
              tr(class: "w-full") do
                td(class: "pl-3 pr-3 pt-6 pb-6") do
                  yield

                  table(
                    width: "100%",
                    border: 0,
                    cellspacing: 0,
                    cellpadding: 0,
                    role: "presentation",
                    class: "mt-6 border-collapse",
                  ) do
                    tr do
                      td(valign: "middle", class: "w-10") do
                        image_tag(
                          "logo.png",
                          alt: "smaller world logo",
                          width: 32,
                          height: 32,
                          class: "imageFix",
                        )
                      end
                      td(valign: "middle") do
                        p(class: "text-xs text-muted-foreground mt-0") do
                          link_to(
                            "smaller world",
                            root_url,
                            target: "_blank",
                            rel: "noopener",
                            class: "text-sm underline!",
                          )
                          br
                          plain("a new way to share your feelings with old friends.")
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
