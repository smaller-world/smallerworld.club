import { Controller } from "@hotwired/stimulus";

type DispatchOptions = Partial<{
  target: Element | Window | Document;
  detail: object;
  prefix: string;
  bubbles: boolean;
  cancelable: boolean;
}>;

export default class ApplicationController<
  ElementType extends Element = Element,
> extends Controller<ElementType> {
  // == Helpers ==

  dispatch(eventName: string, options?: DispatchOptions): CustomEvent<object> {
    if (this.application.debug) {
      this.context.logDebugActivity(`dispatch:${eventName}`, options);
    }
    return super.dispatch(eventName, options);
  }
}
