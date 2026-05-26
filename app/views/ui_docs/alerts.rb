# typed: strict
# frozen_string_literal: true

class Views::UiDocs::Alerts < Views::Base
  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(page_title: [ "ui", "alerts" ]) do |layout|
      layout.page_container do
        div(class: "mx-auto max-w-2xl space-y-10 py-8") do
          # Back link
          a(
            href: ui_docs_path,
            class: "inline-flex items-center gap-1 text-sm text-muted-foreground " \
              "transition-colors hover:text-foreground",
          ) do
            Icon("huge/arrow-left-01", class: "size-5")
            plain("Components")
          end

          # Header
          div(class: "space-y-1") do
            h1(class: "text-3xl font-bold tracking-tight") { "Alert" }
            p(class: "text-muted-foreground") do
              "Displays a callout for user attention."
            end
          end

          # Demo
          div(class: "space-y-4") do
            section_heading("Demo")
            preview_card do
              div(class: "grid w-full max-w-md items-start gap-4") do
                render Components::Alert.new do |alert|
                  Icon("huge/checkmark-circle-01", class: "size-4")
                  alert.title { "Payment successful" }
                  alert.description do
                    "Your payment of $29.99 has been processed. A receipt has " \
                      "been sent to your email address."
                  end
                end

                render Components::Alert.new do |alert|
                  Icon("huge/information-circle", class: "size-4")
                  alert.title { "New feature available" }
                  alert.description do
                    "We've added dark mode support. You can enable it in your " \
                      "account settings."
                  end
                end
              end
            end
          end

          # Usage
          div(class: "space-y-4") do
            section_heading("Usage")
            code_block(<<~RUBY)
              render Components::Alert.new do |alert|
                Icon("huge/information-circle")
                alert.title { "Heads up!" }
                alert.description do
                  "You can add components and dependencies to your app using the cli."
                end
                alert.action do
                  render Components::Button.new(variant: :outline, size: :xs) {
                    "Enable"
                  }
                end
              end
            RUBY
          end

          # Composition
          div(class: "space-y-4") do
            section_heading("Composition")
            code_block(<<~TEXT, language: "text")
              Alert
              ├── Icon
              ├── AlertTitle
              ├── AlertDescription
              └── AlertAction
            TEXT
          end

          # Examples
          div(class: "space-y-6") do
            section_heading("Examples")

            # Basic
            div(class: "space-y-3") do
              example_heading("Basic")
              p(class: "text-sm text-muted-foreground") do
                "A basic alert with an icon, title and description."
              end
              preview_card do
                render Components::Alert.new(class: "max-w-md") do |alert|
                  Icon("huge/checkmark-circle-01", class: "size-4")
                  alert.title { "Account updated successfully" }
                  alert.description do
                    "Your profile information has been saved. Changes will be " \
                      "reflected immediately."
                  end
                end
              end
            end

            # Destructive
            div(class: "space-y-3") do
              example_heading("Destructive")
              p(class: "text-sm text-muted-foreground") do
                plain("Use ")
                code(class: "text-xs bg-muted px-1.5 py-0.5 rounded font-mono") do
                  "variant: :destructive"
                end
                plain(" to create a destructive alert.")
              end
              preview_card do
                render Components::Alert.new(variant: :destructive, class: "max-w-md") do |alert|
                  Icon("huge/alert-01", class: "size-4")
                  alert.title { "Payment failed" }
                  alert.description do
                    "Your payment could not be processed. Please check your " \
                      "payment method and try again."
                  end
                end
              end
            end

            # Action
            div(class: "space-y-3") do
              example_heading("Action")
              p(class: "text-sm text-muted-foreground") do
                plain("Use ")
                code(class: "text-xs bg-muted px-1.5 py-0.5 rounded font-mono") { "alert.action" }
                plain(" to add a button or other action element to the alert.")
              end
              preview_card do
                render Components::Alert.new(class: "max-w-md") do |alert|
                  alert.title { "Dark mode is now available" }
                  alert.description do
                    "Enable it under your profile settings to get started."
                  end
                  alert.action do
                    render Components::Button.new(size: :sm, variant: :default) do
                      "Enable"
                    end
                  end
                end
              end
            end

            # Custom Colors
            div(class: "space-y-3") do
              example_heading("Custom Colors")
              p(class: "text-sm text-muted-foreground") do
                "You can customize the alert colors by adding custom classes."
              end
              preview_card do
                render Components::Alert.new(
                  class: "max-w-md border-amber-200 bg-amber-50 text-amber-900 " \
                    "dark:border-amber-900 dark:bg-amber-950 dark:text-amber-50",
                ) do |alert|
                  Icon("huge/alert-02", class: "size-4")
                  alert.title { "Your subscription will expire in 3 days." }
                  alert.description do
                    "Renew now to avoid service interruption or upgrade to a paid " \
                      "plan to continue using the service."
                  end
                end
              end
            end
          end

          # API Reference
          div(class: "space-y-6") do
            section_heading("API Reference")

            api_section(
              "Alert",
              "The Alert component displays a callout for user attention.",
              [ [ "variant", ":default | :destructive", ":default" ] ],
            )

            api_section(
              "AlertTitle",
              "Displays the title of the alert.",
            )

            api_section(
              "AlertDescription",
              "Displays the description or content of the alert.",
            )

            api_section(
              "AlertAction",
              "Displays an action element positioned in the top-right corner.",
            )
          end
        end
      end
    end
  end

  private

  sig { params(text: String).void }
  def section_heading(text)
    h2(class: "text-xl font-semibold tracking-tight") { text }
  end

  sig { params(text: String).void }
  def example_heading(text)
    h3(class: "text-base font-medium") { text }
  end

  sig { params(code: String, language: String).void }
  def code_block(code, language: "ruby")
    pre(class: "rounded-lg border bg-muted/50 p-4 overflow-x-auto") do
      code(class: "text-sm font-mono") { code.strip }
    end
  end

  sig { params(content: T.proc.void).void }
  def preview_card(&content)
    div(
      class: "flex items-center justify-center rounded-lg border p-10",
      &content
    )
  end

  sig { params(name: String, description: String, rows: T::Array[T::Array[String]]).void }
  def api_section(name, description, rows = [])
    div(class: "space-y-3") do
      h3(class: "font-semibold") do
        code(class: "text-sm bg-muted px-1.5 py-0.5 rounded font-mono") { name }
      end
      p(class: "text-sm text-muted-foreground") { description }
      api_table(rows) if rows.any?
    end
  end

  sig { params(rows: T::Array[T::Array[String]]).void }
  def api_table(rows)
    table(class: "w-full text-sm") do
      thead do
        tr(class: "border-b") do
          th(class: "text-left py-2 font-medium text-muted-foreground") { "Prop" }
          th(class: "text-left py-2 font-medium text-muted-foreground") { "Type" }
          th(class: "text-left py-2 font-medium text-muted-foreground") { "Default" }
        end
      end
      tbody do
        rows.each do |row|
          tr(class: "border-b last:border-0") do
            row.each do |cell|
              td(class: "py-2") do
                code(class: "text-xs bg-muted px-1.5 py-0.5 rounded font-mono") { cell }
              end
            end
          end
        end
      end
    end
  end
end
