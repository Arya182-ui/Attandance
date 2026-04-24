import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    host: true,
    // Fix SPA routing - fallback to index.html for all routes
    historyApiFallback: true,
  },
  build: {
    outDir: 'dist',
    sourcemap: false, // Disable for production
    minify: true, // Use default minifier (esbuild)
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          firebase: ['firebase/app', 'firebase/auth', 'firebase/firestore']
        }
      }
    }
  },
  define: {
    __DEV__: false
  }
})