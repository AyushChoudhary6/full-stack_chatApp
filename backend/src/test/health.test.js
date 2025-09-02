import request from 'supertest';
import { app } from '../index.js';

describe('Health Check Endpoints', () => {
  test('GET /health should return 200', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
  });

  test('GET /health should return health status', async () => {
    const response = await request(app).get('/health');
    expect(response.body).toHaveProperty('status');
    expect(response.body.status).toBe('ok');
  });
});

describe('API Status', () => {
  test('Server should be running', () => {
    expect(app).toBeDefined();
  });
});
