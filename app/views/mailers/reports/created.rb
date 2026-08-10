# typed: strict
# frozen_string_literal: true

class Views::Mailers::Reports::Created < Views::Mailers::Base
  # == Initialization ==

  sig { params(report: Report).void }
  def initialize(report:)
    super()
    @report = report
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::MailerLayout() do |mailer_layout|
      mailer_layout.email_container do
        h1(class: "text-2xl") do
          "a #{reportable_label} was reported"
        end

        p(class: "mt-4") do
          plain(
            "#{@report.reporter!.name} reported a #{reportable_label} for: " \
              "#{@report.category.text}",
          )
        end

        if (note = @report.note)
          blockquote(class: "mt-4 pl-3 border-l-2 text-muted-foreground") do
            note
          end
        end

        if @report.reportable_type == "Post"
          p(class: "mt-4") do
            "until it's reviewed, this post is hidden from everyone but its " \
              "author."
          end
        end

        email_button_to([ :admin, @report ], class: "mt-6 mb-3") do
          "review this report"
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def reportable_label
    @report.reportable_type.downcase
  end
end
