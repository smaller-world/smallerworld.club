export const getEnv = (): string => {
  const el = document.querySelector('meta[name="env"]');
  if (!el) {
    throw new Error("Missing environment meta tag");
  }
  const value = el.getAttribute("content");
  if (value === null) {
    throw new Error("Invalid environment meta tag");
  }
  return value;
};

export const isDevelopment = () => getEnv() === "development";
export const isProduction = () => getEnv() === "production";
