declare module "@hotwired/hotwire-native-bridge" {
  import type { Controller } from "@hotwired/stimulus";

  interface BridgeReply<T extends Record<string, unknown>> {
    id: string;
    component: string;
    event: string;
    data: T;
  }

  export interface Bridge {
    supportsComponent(component: string): boolean;
    send(message: {
      component: string;
      event: string;
      data: Record<string, unknown>;
      callback?: (reply: BridgeReply) => void;
    }): string | null;
    removeCallbackFor(messageId: string | null): void;
    removePendingMessagesFor(component: string): void;
  }

  export class BridgeElement {
    constructor(element: Element);
    readonly element: Element;
    readonly title: string;
    readonly enabled: boolean;
    readonly disabled: boolean;
    enableForComponent(component: { enabled: boolean }): void;
    hasClass(className: string): boolean;
    attribute(name: string): string | null;
    bridgeAttribute(name: string): string | null;
    setBridgeAttribute(name: string, value: string): void;
    removeBridgeAttribute(name: string): void;
    click(): void;
    readonly platform: string | undefined;
  }

  export class BridgeComponent extends Controller {
    static component: string;
    static readonly shouldLoad: boolean;

    pendingMessageCallbacks: (string | null)[];

    initialize(): void;
    connect(): void;
    disconnect(): void;

    addRestoreEventListener(): void;
    removeRestoreEventListener(): void;
    restore(): void;

    readonly component: string;
    readonly platformOptingOut: boolean;
    readonly enabled: boolean;

    send<T extends Record<string, unknown>>(
      event: string,
      data: Record<string, unknown> = {},
      callback?: (reply: BridgeReply<T>) => void,
    ): void;
    removePendingCallbacks(): void;
    removePendingMessages(): void;

    readonly bridgeElement: BridgeElement;
    readonly bridge: Bridge;
  }
}
