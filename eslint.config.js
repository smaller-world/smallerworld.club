// @ts-check

/* eslint-disable import-x/no-named-as-default-member */
import { readFileSync } from "node:fs";

import js from "@eslint/js";
import { defineConfig } from "eslint/config";
import eslintConfigPrettier from "eslint-config-prettier/flat";
import { createTypeScriptImportResolver } from "eslint-import-resolver-typescript";
import { importX } from "eslint-plugin-import-x";
import simpleImportSortPlugin from "eslint-plugin-simple-import-sort";
import globals from "globals";
import ts from "typescript-eslint";

const prettierIgnores = readFileSync(".prettierignore", "utf8")
  .split("\n")
  .map((line) => line.trim())
  .filter((line) => !!line);

export default defineConfig([
  { ignores: prettierIgnores },
  js.configs.recommended,
  ts.configs.recommendedTypeChecked,
  ts.configs.stylisticTypeChecked,
  // @ts-expect-error - Bad typing, but it works
  importX.flatConfigs.recommended,
  // @ts-expect-error - Bad typing, but it works
  importX.flatConfigs.typescript,
  {
    settings: {
      "import-x/resolver-next": [
        createTypeScriptImportResolver({
          project: "./tsconfig.json",
        }),
      ],
    },
  },
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
      },
    },
  },
  {
    files: ["*.js"],
    ...ts.configs.disableTypeChecked,
  },
  {
    files: ["*.config.js"],
    languageOptions: {
      globals: {
        ...globals.node,
      },
    },
  },
  {
    files: ["app/javascript/**/*.ts", "app/entrypoints/*.ts"],
    languageOptions: {
      globals: {
        ...globals.browser,
      },
    },
    rules: {
      "@typescript-eslint/no-explicit-any": "off",
      "@typescript-eslint/no-empty-function": "off",
      "@typescript-eslint/no-empty-object-type": "off",
      "@typescript-eslint/no-unused-vars": [
        "warn",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
          caughtErrorsIgnorePattern: "^_",
        },
      ],
      "@typescript-eslint/consistent-type-imports": [
        "warn",
        {
          fixStyle: "inline-type-imports",
        },
      ],
      "@typescript-eslint/consistent-type-exports": [
        "warn",
        {
          fixMixedExportsWithInlineTypeSpecifier: true,
        },
      ],
    },
  },
  {
    files: [
      "*.config.js",
      "app/javascript/**/*.ts",
      "app/{components,helpers,pages}/**/*.{ts,tsx}",
    ],
    plugins: {
      "simple-import-sort": simpleImportSortPlugin,
    },
    rules: {
      "simple-import-sort/imports": [
        "warn",
        {
          groups: [
            // == Node.js builtins prefixed with `node:`
            ["^node:"],

            // == Packages
            // Things that start with a letter (or digit or underscore), or `@`
            // followed by a letter
            ["^@?\\w"],

            // == Absolute imports
            // Anything not matched in another group.
            ["^"],

            // == Project imports
            ["^#/"],

            // == Icons
            ["^~icons/"],

            // == Assets
            ["^~/assets/"],

            // == Relative imports
            // (Anything that starts with a dot.)
            ["^\\."],

            // == CSS modules
            ["\\.module\\.css$"],

            // == Absolute side effect imports
            ["^\\u0000"],

            // == Relative side effect imports
            ["^\\u0000\\."],
          ],
        },
      ],
      "simple-import-sort/exports": "warn",
    },
  },
  eslintConfigPrettier,

  // == Legacy (React frontend)
  // TODO: Remove this once React frontend is gone.
  {
    files: [
      "app/{helpers,components,pages}/**/*.{ts,tsx}",
      "app/entrypoints/deprecated/**.ts",
    ],
    rules: {
      "@typescript-eslint/no-explicit-any": "off",
      "@typescript-eslint/no-empty-function": "off",
      "@typescript-eslint/no-empty-object-type": "off",
      "@typescript-eslint/no-unused-vars": [
        "warn",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
          caughtErrorsIgnorePattern: "^_",
        },
      ],
      "@typescript-eslint/consistent-type-imports": [
        "warn",
        {
          fixStyle: "inline-type-imports",
        },
      ],
      "@typescript-eslint/consistent-type-exports": [
        "warn",
        {
          fixMixedExportsWithInlineTypeSpecifier: true,
        },
      ],
      "@typescript-eslint/no-unsafe-assignment": "off",
      "import-x/no-unresolved": [
        "error",
        {
          ignore: ["^~icons/"],
        },
      ],
    },
  },
]);

// export default ts.config(
//   { ignores: prettierIgnores },
//   js.configs.recommended,
//   ...ts.configs.recommendedTypeChecked,
//   ...ts.configs.stylisticTypeChecked,
//   {
//     languageOptions: {
//       parserOptions: {
//         projectService: true,
//         tsconfigRootDir: import.meta.dirname,
//       },
//     },
//   },
//   {
//     files: ["app/**/*.{ts,tsx,js,jsx}", "vite.config.mjs"],
//     rules: {
//       "no-console": ["warn", { allow: ["debug", "info", "warn", "error"] }],
//     },
//   },
//   {
//     files: ["app/**/*.{ts,tsx}"],
//     rules: {
//       "@typescript-eslint/ban-ts-comment": "off",
//       "@typescript-eslint/no-non-null-assertion": "off",
//       "@typescript-eslint/no-unused-vars": [
//         "warn",
//         {
//           argsIgnorePattern: "^_",
//           varsIgnorePattern: "^_",
//           caughtErrorsIgnorePattern: "^_",
//         },
//       ],
//       "@typescript-eslint/prefer-regexp-exec": "off",
//     },
//   },
//   {
//     files: ["**/*.{js,jsx,mjs}"],
//     ...ts.configs.disableTypeChecked,
//   },
//   {
//     files: ["*.config.mjs", "app/javascript/**/*.{js,jsx}"],
//     ...importPlugin.flatConfigs.recommended,
//     ...importPlugin.flatConfigs.typescript,
//     languageOptions: {
//       ecmaVersion: "latest",
//       sourceType: "module",
//       globals: {
//         ...globals.browser,
//       },
//     },
//       "import/no-unresolved": "off",
//       "import/first": "warn",
//       "import/newline-after-import": "warn",
//       "import/consistent-type-specifier-style": ["warn", "prefer-inline"],
//       "import/namespace": "off",
//     },
//   },
//   {
//     files: ["app/**/*.{js,jsx,ts,tsx}"],
//     ...reactPlugin.configs.flat.recommended,
//     settings: {
//       react: {
//         version: "detect",
//       },
//     },
//     plugins: {
//       "react-refresh": reactRefreshPlugin,
//     },
//     rules: {
//       "react/react-in-jsx-scope": "off",
//       "react/jsx-no-undef": "off",
//       "react/prop-types": "off",
//       "react-refresh/only-export-components": "warn",
//     },
//   },
//   {
//     files: ["app/**/*.{js,jsx,ts,tsx}"],
//     plugins: {
//       "react-hooks": reactHooksPlugin,
//     },
//     // @ts-expect-error react-hooks is not typed
//     rules: {
//       ...reactHooksPlugin.configs.recommended.rules,
//       "react-hooks/exhaustive-deps": [
//         "warn",
//         {
//           additionalHooks: "(useDidUpdate|useShallowEffect)",
//         },
//       ],
//     },
//   },
// );
