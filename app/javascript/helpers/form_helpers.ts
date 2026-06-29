export interface HasValueSetter {
  value: unknown;
}

export const hasValueSetter = (obj: unknown): obj is HasValueSetter => {
  if (typeof obj !== "object" || obj === null) {
    return false;
  }

  let current: any = obj;
  while (current) {
    const desc = Object.getOwnPropertyDescriptor(current, "value");
    if (desc?.set) {
      return true;
    }
    current = Object.getPrototypeOf(current);
  }

  return false;
};
