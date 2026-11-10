# typed: strict
# frozen_string_literal: true

class Views::Admin::Users::Index < Views::Base
  include Phlex::Rails::Helpers::ImageTag

  # == Initialization ==

  sig { params(users: T::Enumerable[User]).void }
  def initialize(users:)
    super()
    @users = users
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: [ "admin", "users" ], disable_cache: true) do |app_layout|
      app_layout.with_navigation(class: "max-w-2xl") do
        button_back_to("admin dashboard", [ :admin, :dashboard ], variant: :secondary)
      end

      app_layout.page_container(class: "max-w-2xl flex flex-col gap-6") do
        div do
          h1(class: "text-2xl") { "development users" }
          p(class: "text-sm text-muted-foreground") { "all local accounts. switching replaces this browser's current session." }
        end

        Components::ItemGroup(class: "gap-3") do
          @users.each do |user|
            Components::Item(variant: :outline) do |item|
              item.content do |content|
                content.title { user.name }
                content.description { user.phone_number }
              end
              item.actions do
                Components::Form(
                  user,
                  action: switch_admin_user_path(user),
                  method: :post,
                  data: { turbo: false },
                ) do |form|
                  form.submit(variant: :secondary, aria: { label: "switch to #{user.name}" }) do
                    "switch to this account"
                  end
                end
              end
            end
          end
        end

        section(class: "flex flex-col gap-3") do
          h2(class: "text-xl") { "seed baseline" }
          p(class: "text-sm text-muted-foreground") do
            "these scenarios and the graph describe the seed baseline and may be stale after " \
              "local edits. other local accounts appear above too."
          end
          div(class: "overflow-x-auto") do
            image_tag(
              "development-seed-graph.svg",
              alt: "seed baseline: directed keys and pending invitations; full scenarios follow below",
              class: "min-w-xl"
            )
          end
          p(class: "text-sm text-muted-foreground") do
            "arrows point from worlds to key recipients; dashed arrows are pending invitations " \
            "and grant no access. repeated names are the same account. default types means all " \
            "four default post types. post counts include intros."
          end
          dl(class: "text-sm flex flex-col gap-3") do
            scenario(
              "alex",
              "owns a world with only its intro and no friends. holds keys to blair's journal " \
                "entries and casey's default post types."
            )
            scenario(
              "blair",
              "owns a world with 60 posts and all four other accounts as friends. shares " \
                "reciprocal keys with casey and ellis. the first generated journal entry is " \
                "hidden from drew and favorited, with a reaction from casey."
            )
            scenario(
              "casey",
              "owns a world with 8 posts, shared with alex and blair, and a quiet corner with " \
                "only its intro and no friends. the custom field note type is shared " \
                "only with blair. has a pending invitation to ellis."
            )
            scenario(
              "drew",
              "owns a world with 3 posts, shared with casey. has a pending invitation to blair. " \
                "reacts to ellis's favorited post."
            )
            scenario(
              "ellis",
              "owns a world with 15 posts, shared with blair and drew. mutes blair's poems and " \
                "has a favorited post with drew's reaction."
            )
            scenario(
              "read state and notifications",
              "keys held by blair were visited now; other keys were visited a week ago. posts " \
                "span recent days. four delivered notification examples cover a post, reaction, " \
                "accepted key, and pending invitation; only the reaction is marked received."
            )
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(name: String, description: String).void }
  def scenario(name, description)
    div do
      dt(class: "font-heading font-semibold") { name }
      dd(class: "text-muted-foreground") { description }
    end
  end
end
