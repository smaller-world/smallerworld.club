// @ts-check

/* eslint-disable import-x/no-named-as-default-member */
import js from "@eslint/js";
import { defineConfig } from "eslint/config";
import eslintConfigPrettier from "eslint-config-prettier/flat";
import { createTypeScriptImportResolver } from "eslint-import-resolver-typescript";
import { importX } from "eslint-plugin-import-x";
import simpleImportSortPlugin from "eslint-plugin-simple-import-sort";
import { readFileSync } from "fs";
import globals from "globals";
import ts from "typescript-eslint";

const prettierIgnores = readFileSync(".prettierignore", "utf8")
  .split("\n")
  .map((line) => line.trim())
  .filter((line) => !!line);

export default defineConfig([
  { ignores: prettierIgnores },
  js.configs.recommended,
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
    files: ["**/*.{ts,tsx}"],
    extends: [
      ...ts.configs.recommendedTypeChecked,
      ...ts.configs.stylisticTypeChecked,
    ],
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
    files: ["app/javascript/**/*.js"],
    languageOptions: {
      globals: {
        ...globals.browser,
      },
    },
  },
  {
    files: ["app/javascript/**/*.ts"],
    languageOptions: {
      globals: {
        ...globals.browser,
      },
    },
    rules: {
      "@typescript-eslint/no-explicit-any": "off",
      "@typescript-eslint/no-empty-function": "off",
      "@typescript-eslint/no-empty-object-type": "off",
      "@typescript-eslint/no-unsafe-assignment": "off",
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
      "@typescript-eslint/class-literal-property-style": "off",
    },
  },
  {
    files: ["*.config.js", "app/javascript/**/*.{js,ts}"],
    plugins: {
      "simple-import-sort": simpleImportSortPlugin,
    },
    rules: {
      "simple-import-sort/imports": [
        "warn",
        {
          groups: [
            // Node.js builtins prefixed with `node:`
            ["^node:"],

            // Packages: Things that start with a letter (or digit or
            // underscore), or `@` followed by a letter.
            ["^@?\\w"],

            // Absolute imports: Anything not matched in another group.
            ["^"],

            // Project imports
            ["^#/"],

            // Relative imports: Anything that starts with a dot.
            ["^\\."],

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
]);
