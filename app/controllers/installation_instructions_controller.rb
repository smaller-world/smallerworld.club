# typed: true
# frozen_string_literal: true

class InstallationInstructionsController < PublicController
  # == Actions ==

  # GET /install
  def show
    questions_params = params.permit(:platform, :testflight_installed)
    questions = InstallationInstructionsQuestions.new(questions_params)
    render Views::InstallationInstructions::Show.new(questions:)
  end
end
