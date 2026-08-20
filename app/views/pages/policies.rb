# typed: strict
# frozen_string_literal: true

class Views::Pages::Policies < Views::Base
  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "policies") do |app_layout|
      app_layout.page_container(class: "flex flex-col gap-6 max-w-3xl") do
        header
        column_headers
        sections.each do |section|
          policy_section(
            friendly_title: section.fetch(:friendly_title),
            friendly: section.fetch(:friendly),
            legal_title: section.fetch(:legal_title),
            legal: section.fetch(:legal),
          )
        end
      end
    end
  end

  private

  # == Sections ==

  sig { returns(T::Array[T::Hash[Symbol, T.untyped]]) }
  def sections
    [
      {
        friendly_title: "Welcome to Smaller World.",
        friendly: -> {
          plain("This is your private space to share what matters — just with " \
            "people you invite. By using our app, you agree to these terms.")
        },
        legal_title: "Acceptance of Terms",
        legal: -> {
          plain('By accessing or using the Smaller World platform ("the ' \
            'Service"), you agree to be bound by these Terms of Service and ' \
            "our Privacy Policy. If you do not agree, do not use the Service.")
        },
      },
      {
        friendly_title: "Your Stuff Is Yours.",
        friendly: -> {
          plain("Everything you post stays private unless ")
          i { "you" }
          plain(" choose to share it. We ")
          b { "don't read your posts" }
          plain(", and we'll ")
          b { "never tie your name or identity to what you write" }
          plain(". If we ever use data for research or to improve the app, " \
            "we'll make sure it's fully anonymous — only computers will " \
            "process it, not people.")
        },
        legal_title: "User Content & Data Ownership",
        legal: -> {
          plain("Users retain full ownership of all content they post. Smaller " \
            "World will not access or disclose user-generated content except " \
            "as required by law or in cases of suspected abuse. We do not " \
            "sell or share personally identifiable data. We may use " \
            "anonymized, aggregated data for research, analytics, or business " \
            "purposes. All such data is stripped of personally identifying " \
            "information and processed in a way that prevents re-identification.")
        },
      },
      {
        friendly_title: "We keep things minimal.",
        friendly: -> {
          plain("We only collect what we need — your phone number, posts, and " \
            "how you use the app (so we can improve it).")
        },
        legal_title: "Data Collection",
        legal: -> {
          plain("We collect personal data including email addresses, " \
            "user-generated content, and limited analytics data solely for " \
            "the purpose of providing and improving the Service.")
        },
      },
      {
        friendly_title: "Your phone number stays private.",
        friendly: -> {
          plain("We use your phone number to help you sign in. We don't sell it " \
            "or share your agreement to receive texts for advertising.")
        },
        legal_title: "SMS Data Privacy",
        legal: -> {
          plain("Smaller World does not sell, rent, or share mobile phone " \
            "numbers, SMS opt-in data, or SMS consent with third parties for " \
            "their promotional or marketing purposes. We may share this " \
            "information only with service providers that help us provide the " \
            "Service, including phone carriers and messaging providers, and " \
            "only as necessary to deliver login verification messages.")
        },
      },
      {
        friendly_title: "You can leave anytime.",
        friendly: -> {
          plain("Delete your account and we'll delete your data.")
        },
        legal_title: "Account Termination",
        legal: -> {
          plain("Users may terminate their account at any time. Upon request, " \
            "Smaller World will delete associated personal data in accordance " \
            "with applicable data protection laws.")
        },
      },
      {
        friendly_title: "About text messages.",
        friendly: -> {
          plain("We only text you when someone requests a login code using your " \
            "phone number. We send one code for each login attempt. Message " \
            "and data rates may apply. Reply STOP to stop texts, START to " \
            "receive them again, or HELP for help.")
        },
        legal_title: "SMS Login Verification",
        legal: -> {
          plain("By providing your phone number and requesting a login code, you " \
            "agree to receive one SMS verification code from Smaller World for " \
            "each login attempt. Message and data rates may apply. Reply STOP to " \
            "opt out of SMS messages, START to opt back in, or HELP for help. " \
            "Smaller World does not send marketing text messages through this " \
            "program. For support, ")
          a(href: contact_href, class: contact_link_class) do
            "please contact us by email"
          end
          plain(".")
        },
      },
      {
        friendly_title: "Be kind. Don't spam. Don't be creepy.",
        friendly: -> {
          plain("If someone's using the app in a harmful or exploitative way, " \
            "we may suspend them.")
        },
        legal_title: "Acceptable Use",
        legal: -> {
          plain("Users must not engage in abusive, harassing, unlawful, or " \
            "disruptive behavior. Smaller World reserves the right to suspend " \
            "or terminate access for users violating these terms.")
        },
      },
      {
        friendly_title: "We do our best.",
        friendly: -> {
          plain("Things may go wrong sometimes — bugs happen. Please use the " \
            "app at your own risk.")
        },
        legal_title: "Disclaimer of Warranty",
        legal: -> {
          plain('The Service is provided "as is." Smaller World disclaims all ' \
            "warranties, express or implied. We are not liable for any " \
            "damages resulting from the use of the platform.")
        },
      },
      {
        friendly_title: "We might update this.",
        friendly: -> {
          plain("If something big changes, we'll let you know.")
        },
        legal_title: "Modifications",
        legal: -> {
          plain("We reserve the right to modify these terms at any time. " \
            "Material changes will be communicated via email or in-app " \
            "notification. Continued use constitutes acceptance.")
        },
      },
      {
        friendly_title: "Where all this applies.",
        friendly: -> {
          plain("If anything ever gets weird and legal, it'll be handled under " \
            "Canadian law — more specifically, in Ontario.")
        },
        legal_title: "Governing Law & Jurisdiction",
        legal: -> {
          plain("These Terms of Service shall be governed by and construed in " \
            "accordance with the laws of the Province of Ontario and the " \
            "federal laws of Canada applicable therein, without regard to " \
            "conflict of law principles. Any disputes arising from or " \
            "relating to these Terms or the use of the Service shall be " \
            "subject to the exclusive jurisdiction of the courts in Ontario, " \
            "Canada.")
        },
      },
      {
        friendly_title: "This might change someday.",
        friendly: -> {
          plain("Right now, Ontario law applies. If Smaller World grows or " \
            "moves, we might need to change our legal home — but we'll update " \
            "you clearly if we do.")
        },
        legal_title: "Change of Jurisdiction",
        legal: -> {
          plain("Smaller World is currently governed by the laws of Ontario, " \
            "Canada. However, we reserve the right to update the governing " \
            "jurisdiction if our legal or operational structure changes " \
            "(e.g., incorporation in another jurisdiction). Any such changes " \
            "will be communicated to users in advance and reflected in the " \
            "updated Terms of Service.")
        },
      },
      {
        friendly_title: "Got questions?",
        friendly: -> {
          a(href: contact_href, class: contact_link_class) { "Email us anytime." }
        },
        legal_title: "Contact",
        legal: -> {
          plain("For questions regarding these terms, our privacy practices, or " \
            "SMS login verification, ")
          a(href: contact_href, class: contact_link_class) do
            "please contact us by email"
          end
          plain(".")
        },
      },
    ]
  end

  # == Components ==

  sig { void }
  def header
    div(class: "flex flex-col items-center gap-1 text-center") do
      h1(class: "font-heading text-2xl font-semibold text-balance sm:text-3xl lg:mt-8") do
        "Terms of Use & Privacy Policy"
      end
      p(class: "text-sm text-muted-foreground") do
        "Last updated: July 17, 2025"
      end
    end
  end

  sig { void }
  def column_headers
    div(class: "hidden gap-8 sm:grid sm:grid-cols-2") do
      div(class: "flex justify-center") do
        Components::Badge(variant: :secondary, class: "h-auto gap-1.5 py-1 text-sm") do
          plain("Spoken like a human bean")
          span(class: "font-emoji") { "🫘" }
        end
      end
      div(class: "flex justify-center") do
        Components::Badge(variant: :secondary, class: "h-auto gap-1.5 py-1 text-sm") do
          plain("Legal Version")
          span(class: "font-emoji") { "⚖️" }
        end
      end
    end
  end

  sig do
    params(
      friendly_title: String,
      friendly: T.proc.void,
      legal_title: String,
      legal: T.proc.void,
    ).void
  end
  def policy_section(friendly_title:, friendly:, legal_title:, legal:)
    div(class: [
      "grid gap-5 rounded-xl bg-card p-6 text-card-foreground shadow-xs ring-1 ring-foreground/10",
      "sm:grid-cols-2 sm:gap-8 sm:rounded-none sm:bg-transparent sm:p-0 sm:shadow-none sm:ring-0",
    ]) do
      content_block(friendly_title, friendly)
      section_divider
      content_block(legal_title, legal, muted: true)
    end
  end

  sig { params(title: String, body: T.proc.void, muted: T::Boolean).void }
  def content_block(title, body, muted: false)
    div(class: "flex flex-col gap-1.5") do
      h2(class: "font-heading text-base leading-normal font-medium") { title }
      div(class: [
        "text-sm leading-relaxed",
        muted ? "text-muted-foreground" : "text-foreground/80",
      ]) do
        body.call
      end
    end
  end

  sig { void }
  def section_divider
    div(class: "flex items-center gap-3 sm:hidden") do
      span(class: "h-px flex-1 bg-border")
      span(class: "flex items-center gap-1.5 text-xs whitespace-nowrap text-muted-foreground") do
        span(class: "font-emoji") { "⬆️" }
        plain("simplified")
        span(class: "opacity-40") { "/" }
        plain("legal")
        span(class: "font-emoji") { "⬇️" }
      end
      span(class: "h-px flex-1 bg-border")
    end
  end

  # == Helpers ==

  sig { returns(String) }
  def contact_link_class
    "font-medium text-primary underline-offset-4 hover:underline"
  end

  sig { returns(String) }
  def contact_href
    encoded_subject = ERB::Util.url_encode("Terms of Use & Privacy Policy")
    email_address = ActionMailer::Base.email_address_with_name(
      SmallerWorld.application.contact_email_address,
      "smaller world team",
    )
    "mailto:#{email_address}?subject=#{encoded_subject}"
  end
end
