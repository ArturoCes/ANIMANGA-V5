// Redirige /api/* al backend en desarrollo. Cambia el destino con API_URL,
// por ejemplo: API_URL=http://localhost:8081 npm start
module.exports = {
  '/api': {
    target: process.env.API_URL || 'http://localhost:8080',
    secure: false,
    changeOrigin: true,
    pathRewrite: { '^/api': '' },
  },
};
