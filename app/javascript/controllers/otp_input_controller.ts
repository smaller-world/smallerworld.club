import { Controller } from "@hotwired/stimulus";

export default class OtpInputController extends Controller {
  // == Targets ==

  static targets = ["input", "slot", "caretTemplate"];
  declare readonly inputTarget: HTMLInputElement;
  declare readonly slotTargets: HTMLElement[];
  declare readonly caretTemplateTarget: HTMLTemplateElement;
  declare readonly hasInputTarget: boolean;
  declare readonly hasCaretTemplateTarget: boolean;

  // == Values ==

  static values = {
    maxLength: { type: Number },
    pattern: { type: String },
  };
  declare readonly maxLengthValue: number;
  declare readonly patternValue: string;

  // == Lifecycle ==

  connect(): void {
    if (!this.hasInputTarget) {
      throw new Error("Missing input target");
    }
    this.updateSlots();
  }

  // == Actions ==

  updateSlots(): void {
    const value = this.inputTarget.value;
    const activeIndex = Math.min(value.length, this.maxLengthValue - 1);

    const isFocused = this.#isFocused;
    for (const slot of this.slotTargets) {
      const { otpInputIndex } = slot.dataset;
      if (!otpInputIndex) {
        continue;
      }

      const index = parseInt(otpInputIndex);
      const char = value[index];
      const isActive = isFocused && index === activeIndex;

      // Update slot state
      if (isActive) {
        slot.dataset.active = "true";
      } else {
        delete slot.dataset.active;
      }

      // Update slot content
      if (char) {
        slot.textContent = char;
      } else if (isActive && this.hasCaretTemplateTarget) {
        const caret = this.caretTemplateTarget.cloneNode();
        slot.replaceChildren(caret);
      }
    }
  }

  processInput(): void {
    const value = this.#filterInputValue();
    this.updateSlots();

    // Notify when complete
    if (this.#isComplete) {
      this.dispatch("complete", { detail: { value } });
    }
  }

  filterKey(event: KeyboardEvent): void {
    // Allow navigation and deletion
    if (
      ["Backspace", "Delete", "ArrowLeft", "ArrowRight", "Tab"].includes(
        event.key,
      )
    ) {
      return;
    }

    // Allow paste
    if ((event.metaKey || event.ctrlKey) && event.key === "v") {
      return;
    }

    // Block invalid characters
    const pattern = new RegExp(this.patternValue);
    if (!pattern.test(event.key)) {
      event.preventDefault();
    }
  }

  // == Helpers ==

  get #isFocused(): boolean {
    return document.activeElement === this.inputTarget;
  }

  get #isComplete(): boolean {
    return this.inputTarget.value.length === this.maxLengthValue;
  }

  #filterInputValue(): string {
    const { value } = this.inputTarget;
    const pattern = new RegExp(this.patternValue, "g");
    const matchedChars = value.match(pattern) ?? [];
    const newValue = matchedChars.join("").slice(0, this.maxLengthValue);
    this.inputTarget.value = newValue;
    return newValue;
  }
}
