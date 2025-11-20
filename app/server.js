const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', version: process.env.APP_VERSION || '1.0.0' });
});

// Main endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'DÉMO POUR MON MAÎTRE DE STAGE - Pipeline CI/CD Automatisé! 🎉',
    version: process.env.APP_VERSION || '1.0.0',
    hostname: require('os').hostname(),
    timestamp: new Date().toISOString()
  });
});

// API endpoint
app.get('/api/info', (req, res) => {
  res.json({
    app: 'k8s-cicd-demo',
    version: process.env.APP_VERSION || '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    uptime: process.uptime()
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Version: ${process.env.APP_VERSION || '1.0.0'}`);
});
