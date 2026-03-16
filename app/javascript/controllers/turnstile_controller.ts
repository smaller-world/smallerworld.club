import { Controller } from "@hotwired/stimulus";

export default class TurnstileController extends Controller<HTMLElement> {
  // == Values ==

  static values = {
    siteKey: String,
  };
  declare readonly siteKeyValue: string;

  // == State ==

  #widgetId: string | null = null;
  #onApiReady: (() => void) | null = null;
  #onBeforeCache: (() => void) | null = null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.#onBeforeCache = () => this.destroy();
    document.addEventListener("turbo:before-cache", this.#onBeforeCache);
    if (typeof turnstile !== "undefined") {
      this.#renderWidget();
    } else {
      this.#onApiReady = () => this.#renderWidget();
      window.addEventListener("turnstile:api-ready", this.#onApiReady);
    }
  }

  disconnect(): void {
    super.disconnect();
    this.destroy();
  }

  // == Actions ==

  destroy(): void {
    if (this.#onBeforeCache) {
      document.removeEventListener("turbo:before-cache", this.#onBeforeCache);
      this.#onBeforeCache = null;
    }
    if (this.#onApiReady) {
      window.removeEventListener("turnstile:api-ready", this.#onApiReady);
      this.#onApiReady = null;
    }
    if (this.#widgetId != null && typeof turnstile !== "undefined") {
      turnstile.remove(this.#widgetId);
      this.#widgetId = null;
    }
  }

  // == Helpers ==

  #renderWidget(): void {
    this.#widgetId =
      turnstile.render(this.element, {
        sitekey: this.siteKeyValue,
        size: "flexible",
        callback: (token: string) => {
          window.dispatchEvent(
            new CustomEvent("turnstile:success", { detail: { token } }),
          );
        },
        "expired-callback": () => {
          window.dispatchEvent(new CustomEvent("turnstile:expired"));
        },
        "error-callback": (errorCode: string) => {
          window.dispatchEvent(
            new CustomEvent("turnstile:error", { detail: { errorCode } }),
          );
        },
      }) ?? null;
  }
}
