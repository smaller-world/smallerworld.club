import { Controller } from "@hotwired/stimulus";
import { useDebounce } from "stimulus-use";
import invariant from "tiny-invariant";

import { hasValueSetter } from "#helpers/form_helpers";

export default class PostDraftController extends Controller<HTMLFormElement> {
  // == Configuration ==

  static debounces = ["save"];

  // == Values ==

  static values = { localStorageKey: String };
  declare readonly localStorageKeyValue: string;

  // == Lifecycle ==

  initialize(): void {
    super.initialize();
    useDebounce(this);
  }

  connect(): void {
    super.connect();
    invariant(this.localStorageKeyValue, "Missing localStorageKey value");
    this.restore();
  }

  disconnect(): void {
    super.disconnect();
  }

  // == Actions ==

  save(): void {
    const value = this.#serializeFormData();
    localStorage.setItem(this.localStorageKeyValue, value);
  }

  restore(): void {
    const formData = this.#reconstructFormData();
    formData.forEach((value, key) => {
      if (value instanceof File) {
        return;
      }
      const input = this.element.elements.namedItem(key);
      if (
        input instanceof HTMLInputElement ||
        input instanceof HTMLSelectElement ||
        hasValueSetter(input)
      ) {
        input.value = value;
      } else {
        console.warn(`Couldn't restore ${key}`, { value, input });
      }
    });
  }

  clear(): void {
    localStorage.removeItem(this.localStorageKeyValue);
  }

  // == Helpers ==

  #serializeFormData(): string {
    const formData = new FormData(this.element);
    formData.delete("authenticity_token");
    formData.delete("_method");
    // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
    const searchParams = new URLSearchParams(formData as any);
    return searchParams.toString();
  }

  #reconstructFormData(): FormData {
    const formData = new FormData();
    const value = localStorage.getItem(this.localStorageKeyValue);
    if (value) {
      const searchParams = new URLSearchParams(value);
      searchParams.forEach((value, key) => {
        formData.append(key, value);
      });
    }
    return formData;
  }
}
