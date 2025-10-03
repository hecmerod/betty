module.exports = {
  apps: [
    {
      name: 'betty-server',
      script: 'dist/apps/betty/main.js',
      instances: 1, // Para Raspberry Pi, usar 1 instancia para evitar sobrecarga
      exec_mode: 'fork', // Fork mode es más estable en ARM
      max_memory_restart: '200M', // Reiniciar si usa más de 200MB (optimizado para RPi)
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        HOST: '0.0.0.0', // Importante: escuchar en todas las interfaces para acceso externo
      },
      env_development: {
        NODE_ENV: 'development',
        PORT: 3000,
        HOST: '0.0.0.0',
      },
      // Configuraciones específicas para Raspberry Pi
      node_args: '--max-old-space-size=512', // Limitar memoria heap a 512MB
      max_restarts: 10,
      min_uptime: '10s',
      // Logs
      log_file: './logs/combined.log',
      out_file: './logs/out.log',
      error_file: './logs/error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      // Monitoreo
      monitoring: false, // Deshabilitado para ahorrar recursos
    },
  ],
};
