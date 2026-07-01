import { Controller } from "@hotwired/stimulus";

export default class StreamedLogMessageController extends Controller<HTMLTemplateElement> {
  // == Values ==

  static values = {
    logLevel: String,
    controllerName: String,
    actionName: String,
  };
  declare readonly logLevelValue: string;
  declare readonly controllerNameValue: string;
  declare readonly actionNameValue: string;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.#log();
  }

  // == Helpers ==

  #log(): void {
    const { textContent } = this.element.content;
    const args = [
      `%c${this.controllerNameValue}#${this.actionNameValue}%c ${textContent}`,
      "font-weight: bold",
      "",
    ];
    switch (this.logLevelValue) {
      case "debug":
        console.debug(...args);
        break;
      case "info":
        console.info(...args);
        break;
      case "warn":
        console.warn(...args);
        break;
      case "error":
        console.error(...args);
        break;
      default:
        console.log(...args);
    }
  }
}
