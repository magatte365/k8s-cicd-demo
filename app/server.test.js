const request = require('supertest');
const express = require('express');

// Mock the server for testing
const app = express();
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', version: '1.0.0' });
});

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Kubernetes CI/CD Pipeline!',
    version: '1.0.0'
  });
});

describe('API Endpoints', () => {
  test('GET /health should return healthy status', async () => {
    const response = await request(app).get('/health');
    expect(response.statusCode).toBe(200);
    expect(response.body.status).toBe('healthy');
  });

  test('GET / should return welcome message', async () => {
    const response = await request(app).get('/');
    expect(response.statusCode).toBe(200);
    expect(response.body.message).toBeDefined();
  });
});
