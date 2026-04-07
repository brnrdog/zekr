import { defineConfig } from "vite"
import { copyFileSync } from "node:fs"
import { resolve } from "node:path"

// SPA fallback for GitHub Pages: any unknown path is served by 404.html,
// which is just a copy of index.html so the client-side router can handle
// the URL on first load.
const spaFallbackPlugin = () => ({
  name: "spa-fallback",
  closeBundle() {
    const dist = resolve(__dirname, "dist")
    copyFileSync(resolve(dist, "index.html"), resolve(dist, "404.html"))
  },
})

export default defineConfig({
  base: "/zekr/",
  plugins: [spaFallbackPlugin()],
  build: {
    outDir: "dist",
    emptyOutDir: true,
  },
  server: {
    port: 3000,
  },
})
