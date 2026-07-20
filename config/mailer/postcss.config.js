// Used only by the email stylesheet build (`build:css:mailer`). The app
// stylesheet is compiled directly with `@tailwindcss/cli`, which ignores this
// file.
//
// Email clients (notably Outlook) don't support CSS custom properties, and
// Premailer — which inlines this stylesheet at render time — doesn't resolve
// them either. So we flatten `var(--…)` theme values into static values here.
export default {
  plugins: {
    "@tailwindcss/postcss": {},
    "postcss-custom-properties": { preserve: false },
    "postcss-calc": {},
    "postcss-rem-to-responsive-pixel": {
      propList: ["*"],
      processorStage: "OnceExit",
    },
    "@csstools/postcss-cascade-layers": {},
    "@csstools/postcss-oklab-function": {
      enableProgressiveCustomProperties: false,
    },
    "@csstools/postcss-color-mix-function": {},
  },
};
