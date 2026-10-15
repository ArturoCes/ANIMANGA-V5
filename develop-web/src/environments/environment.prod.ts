// En producción /api se redirige al backend desde el hosting (ver netlify.toml).
export const environment = {
  production: true,
  apiBaseUrl: '/api/',
};
