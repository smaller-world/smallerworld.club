# typed: true
# frozen_string_literal: true

class ReplyInitiationsController < ApplicationController
  # == Actions ==

  # POST /posts/:post_id/reply_initiations
  def create
    respond_to do |format|
      format.turbo_stream do
        current_user = Current.user!
        post = find_post
        authorize!(post, to: :reply?)
        reply_initiation_params = params.expect(reply_initiation: :platform)
        reply_initiation = post.reply_initiations.build(
          **reply_initiation_params,
          replier: current_user,
        )

        if reply_initiation.save
          render turbo_stream: turbo_stream.replace(
            helpers.dom_id(post, :reply_initiation),
            renderable: Components::ReplyInitiationForm.new(
              reply_initiation:,
              replied: true,
            ),
          )
        else
          message = "Failed to create reply initiation"
          if (error = reply_initiation.errors.full_messages.first)
            message = "#{message}: #{error}"
          end
          Sentry.capture_message(message)
          render(
            turbo_stream: [
              turbo_stream.replace(
                helpers.dom_id(post, :reply_initiation),
                renderable: Components::ReplyInitiationForm.new(
                  reply_initiation:,
                  replied: true,
                ),
              ),
              append_log_message(message, level: :error),
            ],
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(Post) }
  def find_post
    Post.find(params.fetch(:post_id))
  end
end
