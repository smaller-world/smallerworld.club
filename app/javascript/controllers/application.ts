import { Application } from "@hotwired/stimulus";

import { isDevelopment } from "#helpers/env_helpers";

const application = Application.start();

// Configure Stimulus development experience
application.debug = isDevelopment();

// Window hook
declare global {
  interface Window {
    Stimulus: Application;
  }
}
window.Stimulus = application;

export { application };
