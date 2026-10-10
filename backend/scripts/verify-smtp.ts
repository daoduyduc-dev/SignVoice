import { createMailTransport } from '../src/services/mail.service';

async function main(): Promise<void> {
  try {
    const transport = createMailTransport();
    await transport.verify();
    transport.close();
    console.log('SMTP kết nối và xác thực thành công. Chưa gửi email.');
  } catch (error) {
    const code = (error as { code?: string }).code;
    console.error(`SMTP chưa sẵn sàng${code ? ` (${code})` : ''}. Kiểm tra SMTP_USER, SMTP_PASS, cổng và TLS trong backend/.env.`);
    process.exitCode = 1;
  }
}
void main();
