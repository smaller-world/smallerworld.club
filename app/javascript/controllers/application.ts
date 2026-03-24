import { Application } from "@hotwired/stimulus";

const application = Application.start();

// Configure Stimulus development experience
application.debug = true;

// Add to window
declare global {
  interface Window {
    Stimulus: Application;
  }
}
window.Stimulus = application;

export { application };
