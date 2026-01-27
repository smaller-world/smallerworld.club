export const APP_NAMESPACE = "smallerworld";

export const namespacedKey = (...components: string[]): string =>
  [APP_NAMESPACE, ...components].join(":");
