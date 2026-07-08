# typed: strict
# frozen_string_literal: true

class Views::InstallationInstructions::Show < Views::Base
  TESTFLIGHT_APPSTORE_URL = "https://apps.apple.com/us/app/testflight/id899247664?mt=8"

  # == Initialization ==

  sig { params(questions: InstallationInstructionsQuestions).void }
  def initialize(questions:)
    super()
    @questions = questions
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "get the smaller world app :)") do |app_layout|
      app_layout.page_container(class: "flex flex-col gap-6 max-w-sm") do
        h1(class: "text-xl text-center") do
          "let's get you on our iOS beta!"
        end

        Components::FieldSet() do
          Components::Card() do |card|
            card.header(class: "flex flex-col items-center gap-2") do
              image_tag("testflight_logo.png", class: "size-16")
              card.title do
                "do you have the testflight app installed?"
              end
            end
            turbo_frame_tag("installation_instructions_questions") do
              card.content(class: "group-has-[[data-slot=card-footer]]/card:pb-(--card-spacing)") do
                Components::Form(
                  @questions,
                  action: :installation_instructions,
                  method: :get,
                  data: {
                    controller: "submit",
                  },
                ) do |form|
                  form.Field(:testflight_installed).radios([ true, false ]) do |choice|
                    choice.label(class: "cursor-pointer") do
                      Components::Field(orientation: :horizontal, class: "items-center") do |field|
                        span(class: "font-emoji text-lg") do
                          choice.item ? "🖐" : "🤔"
                        end
                        field.content do
                          field.title do
                            if choice.item
                              "yes, i do!"
                            else
                              "no, what's testflight?"
                            end
                          end
                        end
                        choice.input(
                          name: "testflight_installed",
                          data: {
                            action: "change->submit#request",
                          },
                        )
                      end
                    end
                  end
                end
              end
              unless @questions.testflight_installed.nil?
                card.footer(class: "flex flex-col gap-4 items-center border-t", data: {
                  controller: "transition-group",
                }) do
                  if @questions.testflight_installed
                    p(class: "text-center text-balance text-xs text-muted-foreground") do
                      "great! please accept this invitation to test smaller world:"
                    end
                    button_link_to(
                      "open smaller world on testflight",
                      Smallerworld.application.testflight_url,
                      variant: :default,
                      icon: "huge/link-square-01",
                    )
                  else
                    p(class: "text-center text-balance text-xs text-muted-foreground") do
                      "we're not live on the app store yet, so you'll have to use " \
                        "apple's testflight app to install smaller world (for now)."
                    end
                    p(class: [
                      "text-xs text-center text-balance transition-opacity",
                      "has-[+_[data-clicked]]:opacity-50",
                    ]) do
                      plain("first, please install testflight.")
                      br
                      span(class: "font-semibold") do
                        "come back to this page when you're done!"
                      end
                    end

                    button_link_to(
                      "get testflight on the app store",
                      TESTFLIGHT_APPSTORE_URL,
                      variant: :default,
                      icon: "huge/app-store",
                      target: "_blank",
                      class:  "installation-instructions-testflight-button",
                      data: {
                        controller: "click-tracking alert",
                        alert_message_value: "come back to this page after you install testflight!",
                        action: "transition-group#start click-tracking#track alert#alert",
                      },
                    )

                    div(class: "flex flex-col gap-4 hidden starting:opacity-0", data: {
                      transition_group_target: "item",
                      controller: "transition",
                      transition_enter: "transition-opacity duration-200 ease",
                      action: "transition-group:start->transition#enter",
                    }) do
                      p(class: "text-xs text-center text-balance") do
                        "now, install and open testflight. when prompted for an " \
                          "invitation code, just press paste!"
                      end
                      button_link_to(
                        "open smaller world on testflight",
                        Smallerworld.application.testflight_url,
                        variant: :default,
                        icon: "huge/link-square-01",
                        class: "self-center",
                      )
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
