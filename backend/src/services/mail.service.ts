import nodemailer from 'nodemailer';
import { env } from '../config/env';
import { AppError } from '../common/errors/AppError';
import { ErrorCodes } from '../common/errors/errorCodes';

export function assertMailConfigured(): void {
  if (!env.SMTP_HOST || !env.SMTP_USER || !env.SMTP_PASS || !env.SMTP_FROM ||
      !Number.isInteger(env.SMTP_PORT) || env.SMTP_PORT < 1 || env.SMTP_PORT > 65535 ||
      (env.SMTP_PORT === 465 && !env.SMTP_SECURE) || (env.SMTP_PORT === 587 && env.SMTP_SECURE)) {
    throw new AppError('Chức năng gửi email tạm thời chưa khả dụng. Vui lòng thử lại sau.', 503, ErrorCodes.INTERNAL_SERVER_ERROR);
  }
  const origin = new URL(env.PASSWORD_RESET_ORIGIN);
  if ((origin.protocol !== 'https:' && origin.protocol !== 'http:') ||
      (env.isProduction && origin.protocol !== 'https:') || origin.username || origin.password ||
      origin.pathname !== '/' || origin.search || origin.hash) {
    throw new AppError('Chức năng gửi email tạm thời chưa khả dụng. Vui lòng thử lại sau.', 503, ErrorCodes.INTERNAL_SERVER_ERROR);
  }
}

export function createMailTransport() {
  assertMailConfigured();
  return nodemailer.createTransport({
    host: env.SMTP_HOST,
    port: env.SMTP_PORT,
    secure: env.SMTP_SECURE,
    requireTLS: !env.SMTP_SECURE,
    auth: { user: env.SMTP_USER, pass: env.SMTP_PASS.replace(/\s/g, '') },
    connectionTimeout: 10000,
    greetingTimeout: 10000,
    socketTimeout: 15000,
    disableFileAccess: true,
    disableUrlAccess: true,
  });
}

export async function sendPasswordResetEmail(email: string, token: string): Promise<void> {
  const resetUrl = new URL(env.PASSWORD_RESET_ORIGIN);
  // The token is in the fragment, so HTTP requests and referrers do not expose it.
  resetUrl.hash = `/reset-password?token=${token}`;
  const link = resetUrl.toString();
  await createMailTransport().sendMail({
    from: env.SMTP_FROM,
    to: email,
    subject: 'Đặt lại mật khẩu SignVoice',
    text: `Bạn đã yêu cầu đặt lại mật khẩu SignVoice.\n\nMở liên kết sau để đặt mật khẩu mới:\n${link}\n\nLiên kết chỉ dùng được một lần và hết hạn sau 15 phút. Nếu bạn không yêu cầu, hãy bỏ qua email này.`,
  });
}
