declare global {
  interface Window {
    onTurnstileLoad: () => void;
  }
}

window.onTurnstileLoad = function () {
  document.dispatchEvent(new Event("turnstile:load"));
};
