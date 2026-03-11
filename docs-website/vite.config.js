import { defineConfig } from "vite"

export default defineConfig({
  base: "/zekr/",
  build: {
    outDir: "dist",
    emptyOutDir: true,
  },
  server: {
    port: 3000,
  },
})
