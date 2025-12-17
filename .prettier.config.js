/** @type {import("prettier").Config & import('prettier-plugin-jsdoc').Options & import('prettier-plugin-tailwindcss').PluginOptions} */
export default {
  plugins: ["prettier-plugin-jsdoc", "prettier-plugin-tailwindcss"],
  proseWrap: "always",
};
