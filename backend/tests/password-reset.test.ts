import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { randomUUID } from 'crypto';
import request from 'supertest';
import { Application } from 'express';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { User, AccountStatus } from '../src/models/User.model';
import { AuthSession, SessionStatus } from '../src/models/AuthSession.model';
import { UserSettings } from '../src/models/UserSettings.model';
import { AuditLog } from '../src/models/AuditLog.model';
import { hashToken } from '../src/utils/jwt.util';
import * as mail from '../src/services/mail.service';
import { env } from '../src/config/env';

let app: Application;
const ids: string[] = [];
const oldPassword = 'ResetOldPassword123';
const newPassword = 'ResetNewPassword456';
const messages: Array<{email: string; token: string}> = [];
const send = vi.spyOn(mail, 'sendPasswordResetEmail').mockImplementation(async (email, token) => { messages.push({email,token}); });
const previousMail = { user: env.SMTP_USER, pass: env.SMTP_PASS, from: env.SMTP_FROM, origin: env.PASSWORD_RESET_ORIGIN };

beforeAll(async () => {
  env.SMTP_USER = 'sender@example.com'; env.SMTP_PASS = 'test-only'; env.SMTP_FROM = 'sender@example.com';
  env.PASSWORD_RESET_ORIGIN = 'https://signvoice.example.com';
  await connectDatabase();
  app = await createApp();
});

afterAll(async () => {
  await Promise.all([
    User.deleteMany({_id:{$in:ids}}), AuthSession.deleteMany({userId:{$in:ids}}),
    UserSettings.deleteMany({userId:{$in:ids}}), AuditLog.deleteMany({userId:{$in:ids}}),
  ]);
  env.SMTP_USER = previousMail.user; env.SMTP_PASS = previousMail.pass;
  env.SMTP_FROM = previousMail.from; env.PASSWORD_RESET_ORIGIN = previousMail.origin;
  send.mockRestore();
  await disconnectDatabase();
});

async function account() {
  const email = `reset-${randomUUID()}@example.com`;
  const response = await request(app).post('/api/v1/auth/register').send({email,password:oldPassword,displayName:'Reset Test'}).expect(201);
  ids.push(response.body.data.user.id);
  return {email,id:response.body.data.user.id as string,tokens:response.body.data.tokens};
}
async function requestLink(email: string): Promise<string> {
  await request(app).post('/api/v1/auth/forgot-password').send({email}).expect(200);
  const message = messages.filter(item=>item.email===email).at(-1);
  expect(message).toBeDefined();
  return message!.token;
}

describe('SMTP password recovery', () => {
  it('stores only a token hash, never exposes the token in API responses or user data', async () => {
    const user = await account();
    const response = await request(app).post('/api/v1/auth/forgot-password').send({email:user.email.toUpperCase()}).expect(200);
    const token = messages.find(message=>message.email===user.email)!.token;
    expect(token).toMatch(/^[a-f0-9]{64}$/);
    expect(JSON.stringify(response.body)).not.toContain(token);
    const stored = await User.findById(user.id).select('+passwordResetTokenHash +passwordResetExpiresAt');
    expect(stored!.passwordResetTokenHash).toBe(hashToken(token));
    expect(stored!.passwordResetExpiresAt!.getTime()-Date.now()).toBeGreaterThan(14*60000);
    const me = await request(app).get('/api/v1/auth/me').set('Authorization',`Bearer ${user.tokens.accessToken}`).expect(200);
    expect(JSON.stringify(me.body)).not.toContain(hashToken(token));
  });

  it('returns identical responses for unknown accounts and suppresses repeated emails during cooldown', async () => {
    const user = await account();
    const first = await request(app).post('/api/v1/auth/forgot-password').send({email:user.email}).expect(200);
    const unknown = await request(app).post('/api/v1/auth/forgot-password').send({email:`missing-${randomUUID()}@example.com`}).expect(200);
    const repeated = await request(app).post('/api/v1/auth/forgot-password').send({email:user.email}).expect(200);
    expect(unknown.body).toEqual(first.body);
    expect(repeated.body).toEqual(first.body);
    expect(messages.filter(message=>message.email===user.email)).toHaveLength(1);
  });

  it('does not email suspended accounts', async () => {
    const user = await account();
    await User.findByIdAndUpdate(user.id,{status:AccountStatus.SUSPENDED});
    await request(app).post('/api/v1/auth/forgot-password').send({email:user.email}).expect(200);
    expect(messages.filter(message=>message.email===user.email)).toHaveLength(0);
  });

  it('changes the password once, revokes access/refresh sessions, and allows a fresh login and refresh', async () => {
    const user = await account();
    const token = await requestLink(user.email);
    const response = await request(app).post('/api/v1/auth/reset-password').send({token,newPassword}).expect(200);
    expect(response.headers['set-cookie'][0]).toContain('signvoice_refresh=;');
    await request(app).post('/api/v1/auth/reset-password').send({token,newPassword:oldPassword}).expect(400);
    await request(app).get('/api/v1/auth/me').set('Authorization',`Bearer ${user.tokens.accessToken}`).expect(401);
    await request(app).post('/api/v1/auth/refresh').send({refreshToken:user.tokens.refreshToken}).expect(401);
    await request(app).post('/api/v1/auth/login').send({email:user.email,password:oldPassword}).expect(401);
    const login = await request(app).post('/api/v1/auth/login').send({email:user.email,password:newPassword}).expect(200);
    await request(app).get('/api/v1/auth/me').set('Authorization',`Bearer ${login.body.data.tokens.accessToken}`).expect(200);
    await request(app).post('/api/v1/auth/refresh').send({refreshToken:login.body.data.tokens.refreshToken}).expect(200);
    expect(await AuthSession.countDocuments({userId:user.id,status:SessionStatus.ACTIVE})).toBe(2);
  });

  it('rejects expired tokens and weak passwords without consuming a valid link', async () => {
    const user = await account();
    const token = await requestLink(user.email);
    await request(app).post('/api/v1/auth/reset-password').send({token,newPassword:'weak'}).expect(400);
    const stored = await User.findById(user.id).select('+passwordResetTokenHash');
    expect(stored!.passwordResetTokenHash).toBe(hashToken(token));
    await User.findByIdAndUpdate(user.id,{passwordResetExpiresAt:new Date(Date.now()-1)});
    await request(app).post('/api/v1/auth/reset-password').send({token,newPassword}).expect(400);
  });

  it('allows exactly one concurrent reset with the same token', async () => {
    const user = await account();
    const token = await requestLink(user.email);
    const responses = await Promise.all([
      request(app).post('/api/v1/auth/reset-password').send({token,newPassword}),
      request(app).post('/api/v1/auth/reset-password').send({token,newPassword}),
    ]);
    expect(responses.map(response=>response.status).sort()).toEqual([200,400]);
  });

  it('invalidates previous links when a new request is sent after cooldown', async () => {
    const user = await account();
    const old = await requestLink(user.email);
    await User.findByIdAndUpdate(user.id,{passwordResetRequestedAt:new Date(Date.now()-61000)});
    const next = await requestLink(user.email);
    expect(next).not.toBe(old);
    await request(app).post('/api/v1/auth/reset-password').send({token:old,newPassword}).expect(400);
    await request(app).post('/api/v1/auth/reset-password').send({token:next,newPassword}).expect(200);
  });

  it('rejects old session versions even when they remain ACTIVE in the database', async () => {
    const user = await account();
    await User.findByIdAndUpdate(user.id,{$inc:{passwordVersion:1}});
    expect(await AuthSession.countDocuments({userId:user.id,status:SessionStatus.ACTIVE})).toBe(2);
    await request(app).get('/api/v1/auth/me').set('Authorization',`Bearer ${user.tokens.accessToken}`).expect(401);
    await request(app).post('/api/v1/auth/refresh').send({refreshToken:user.tokens.refreshToken}).expect(401);
  });

  it('removes failed email tokens and does not disclose account existence on delivery failure', async () => {
    const user = await account();
    send.mockRejectedValueOnce(new Error('SMTP unavailable'));
    const response = await request(app).post('/api/v1/auth/forgot-password').send({email:user.email}).expect(200);
    expect(response.body.success).toBe(true);
    const stored = await User.findById(user.id).select('+passwordResetTokenHash');
    expect(stored!.passwordResetTokenHash).toBeUndefined();
  });

  it('reports missing SMTP configuration consistently for all addresses', async () => {
    const previous = env.SMTP_PASS;
    env.SMTP_PASS = '';
    try {
      await request(app).post('/api/v1/auth/forgot-password').send({email:'missing@example.com'}).expect(503);
    } finally { env.SMTP_PASS = previous; }
  });

  it('limits excessive recovery requests', async () => {
    const statuses: number[] = [];
    for(let i=0;i<31;i++) {
      const response = await request(app).post('/api/v1/auth/forgot-password').send({email:'nobody@example.com'});
      statuses.push(response.status);
    }
    expect(statuses).toContain(429);
  });
});
