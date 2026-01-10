declare module "#lib/vanilla-otp" {
  export default class VanillaOTP {
    constructor(
      elementOrSelector: string | Element,
      updateToInput?: string | Element | null,
    );
    setEmptyChar(char: string): void;
    getValue(): string;
    setValue(value: string | number): void;
    destroy(): void;
  }
}
