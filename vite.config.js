import { createReadStream, existsSync } from "node:fs";
import { join } from "node:path";

import reactPlugin from "@vitejs/plugin-react";
import Mime from "mime";
import { visualizer as visualizerPlugin } from "rollup-plugin-visualizer";
import iconsPlugin from "unplugin-icons/vite";
import { defineConfig, resolveConfig } from "vite";
import environmentPlugin from "vite-plugin-environment";
import fullReloadPlugin from "vite-plugin-full-reload";
import { ViteImageOptimizer as imageOptimizerPlugin } from "vite-plugin-image-optimizer";
import { isomorphicImport as isomorphicImportPlugin } from "vite-plugin-isomorphic-import";
import { VitePWA as pwaPlugin } from "vite-plugin-pwa";
import rubyPlugin from "vite-plugin-ruby";
import stimulusHmrPlugin from "vite-plugin-stimulus-hmr";

export default defineConfig(async ({ command, mode, isPreview }) => {
  // == Resolve Vite Ruby configuration
  const { base, env } = await resolveConfig(
    {
      configFile: false,
      plugins: [rubyPlugin()],
    },
    command,
    mode,
    undefined,
    isPreview,
  );
  const { VITE_RUBY_ROOT, VITE_RUBY_SOURCE_CODE_DIR, VITE_RUBY_PUBLIC_DIR } =
    env;
  const srcDir = join(VITE_RUBY_ROOT, VITE_RUBY_SOURCE_CODE_DIR);
  const publicDir = join(VITE_RUBY_ROOT, VITE_RUBY_PUBLIC_DIR);

  // == Plugins
  /** @type {import("vite").PluginOption[]} */
  const plugins = [
    environmentPlugin(
      { RAILS_ENV: "development" },
      { defineOn: "import.meta.env" },
    ),
    ignoringCssIsomorphicImportPlugin(),
    iconsPlugin({ compiler: "jsx", jsx: "react" }),
    imageOptimizerPlugin({ includePublic: false }),
    reactPlugin(),
    rubyPlugin(),
    stimulusHmrPlugin(),
    pwaPlugin({
      registerType: "autoUpdate",
      manifest: false,
      strategies: "injectManifest",
      injectRegister: null,
      injectManifest: {
        swSrc: "app/javascript/sw.ts",
        modifyURLPrefix: {
          "": base,
        },
      },
      srcDir: "javascript",
      filename: "sw.ts",
      devOptions: {
        enabled: true,
        type: "module",
      },
    }),
    fullReloadPlugin(["app/views/**/*"]),
  ];

  // == Filesystem fallback
  // For serving static assets referenced by the SSR server.
  plugins.push({
    name: "filesystem-fallback",
    apply: "serve",
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        if (!req.url) {
          return next();
        }
        const filePath = join(publicDir, req.url);
        if (!existsSync(filePath)) {
          return next();
        }
        const contentType = Mime.getType(filePath);
        if (!contentType) {
          return next();
        }
        res.setHeader("Content-Type", contentType);
        createReadStream(filePath).pipe(res);
      });
    },
  });

  // == Visualizer
  const visualize = process.env.VITE_VISUALIZE;
  if (visualize && ["1", "true", "t"].includes(visualize.toLowerCase())) {
    plugins.push(
      visualizerPlugin({
        filename: "tmp/vite_visualize.html",
        open: true,
      }),
    );
  }

  /** @type {import("vite").UserConfig} */
  const config = {
    clearScreen: false,
    resolve: {
      alias: [
        {
          find: "lodash",
          replacement: "lodash-es",
        },
        {
          find: "~stylesheets",
          replacement: join(srcDir, "assets/stylesheets"),
        },
        {
          find: "~helpers",
          replacement: join(srcDir, "javascript/helpers"),
        },
      ],
    },
    build: {
      rollupOptions: {
        onwarn(warning, warn) {
          // Suppress "Module level directives cause errors when bundled"
          // warnings.
          if (warning.code === "MODULE_LEVEL_DIRECTIVE") {
            return;
          }
          warn(warning);
        },
      },
    },
    ssr: {
      noExternal:
        process.env.RAILS_ENV === "production"
          ? true
          : ["@microsoft/clarity", "@wordpress/wordcount"],
    },
    plugins,
  };
  return config;
});

const ignoringCssIsomorphicImportPlugin = () => {
  const plugin = isomorphicImportPlugin({
    client: ["@hotwired/turbo", "@rails/activestorage"],
  });

  const isCssFile = (id) => {
    // Strip query parameters and hash before checking
    const pathWithoutQuery = id.split("?")[0].split("#")[0];
    return pathWithoutQuery.endsWith(".css");
  };

  return {
    ...plugin,
    transform(code, id, options) {
      // Skip CSS files
      if (isCssFile(id)) {
        return null;
      }
      // Call original transform if it exists
      if (plugin.transform) {
        return plugin.transform.call(this, code, id, options);
      }
    },
    load(id, options) {
      // Skip CSS files
      if (isCssFile(id)) {
        return null;
      }
      // Call original load if it exists
      if (plugin.load) {
        return plugin.load.call(this, id, options);
      }
    },
    resolveId(id, importer, options) {
      // Skip CSS files
      if (isCssFile(id)) {
        return null;
      }
      // Call original resolveId if it exists
      if (plugin.resolveId) {
        return plugin.resolveId.call(this, id, importer, options);
      }
    },
  };
};
