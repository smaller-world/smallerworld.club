export const getEnv = (): string => {
  const el = document.querySelector("meta[name='env']");
  if (!el) {
    throw new Error("Missing <meta name='env'> in document head");
  }
  const value = el.getAttribute("content");
  if (value === null) {
    throw new Error("Missing <meta name='env'> content");
  }
  return value;
};

export const isDevelopment = () => getEnv() === "development";
export const isProduction = () => getEnv() === "production";
