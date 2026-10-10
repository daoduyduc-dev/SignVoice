import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { Application } from 'express';

let app: Application;

beforeAll(async () => {
  await connectDatabase();
  app = await createApp();
});

afterAll(async () => {
  await disconnectDatabase();
});

describe('Dictionary API', () => {
  describe('GET /api/v1/dictionary', () => {
    it('should get published dictionary entries', async () => {
      const response = await request(app)
        .get('/api/v1/dictionary')
        .expect(200);
      
      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });
    
    it('should support pagination', async () => {
      const response = await request(app)
        .get('/api/v1/dictionary?limit=5&skip=0')
        .expect(200);
      
      expect(response.body.success).toBe(true);
      expect(response.body.pagination).toBeDefined();
    });
  });
  
  describe('GET /api/v1/dictionary/popular', () => {
    it('should get popular entries', async () => {
      const response = await request(app)
        .get('/api/v1/dictionary/popular')
        .expect(200);
      
      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });
  
  describe('GET /api/v1/categories', () => {
    it('should get active categories', async () => {
      const response = await request(app)
        .get('/api/v1/categories')
        .expect(200);
      
      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });
});
