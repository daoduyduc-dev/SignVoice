import { afterEach, describe, expect, it, vi } from 'vitest';
import nodemailer from 'nodemailer';
import { env } from '../src/config/env';
import { assertMailConfigured, sendPasswordResetEmail } from '../src/services/mail.service';

const previous = {host:env.SMTP_HOST,user:env.SMTP_USER,pass:env.SMTP_PASS,from:env.SMTP_FROM,port:env.SMTP_PORT,secure:env.SMTP_SECURE,origin:env.PASSWORD_RESET_ORIGIN};
afterEach(()=>{
  env.SMTP_HOST=previous.host;env.SMTP_USER=previous.user;env.SMTP_PASS=previous.pass;env.SMTP_FROM=previous.from;
  env.SMTP_PORT=previous.port;env.SMTP_SECURE=previous.secure;env.PASSWORD_RESET_ORIGIN=previous.origin;
  vi.restoreAllMocks();
});

describe('Gmail SMTP configuration',()=>{
  it.each([[465,true],[587,false]] as const)('uses TLS correctly on port %i and creates a fragment reset link',async(port,secure)=>{
    env.SMTP_USER='sender@gmail.com';env.SMTP_PASS='abcd efgh ijkl mnop';env.SMTP_FROM='SignVoice <sender@gmail.com>';
    env.SMTP_PORT=port;env.SMTP_SECURE=secure;env.PASSWORD_RESET_ORIGIN='https://public.conveyor.cloud';
    const sendMail = vi.fn().mockResolvedValue({});
    const create = vi.spyOn(nodemailer,'createTransport').mockReturnValue({sendMail} as any);
    const token='a'.repeat(64);
    await sendPasswordResetEmail('recipient@example.com',token);
    expect(create).toHaveBeenCalledWith(expect.objectContaining({host:'smtp.gmail.com',port,secure,requireTLS:!secure,auth:{user:'sender@gmail.com',pass:'abcdefghijklmnop'}}));
    const message = sendMail.mock.calls[0][0];
    expect(message.to).toBe('recipient@example.com');
    const link = message.text.match(/https:\/\/[^\s]+/)[0];
    const url = new URL(link);
    expect(url.search).toBe('');
    expect(url.hash).toBe(`#/reset-password?token=${token}`);
    expect(message.text).toContain('15 phút');
  });

  it('rejects missing credentials or a mismatched secure port',()=>{
    env.SMTP_PASS='';expect(()=>assertMailConfigured()).toThrow();
    env.SMTP_USER='sender@gmail.com';env.SMTP_PASS='valid';env.SMTP_FROM='sender@gmail.com';
    env.SMTP_PORT=587;env.SMTP_SECURE=true;expect(()=>assertMailConfigured()).toThrow();
  });
});
