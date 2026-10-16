// Executed before application imports. Never fall back to the user's normal database.
const testUri = process.env.TEST_MONGODB_URI;
if (!testUri) throw new Error('Tests require explicit TEST_MONGODB_URI targeting signvoice_test_*');
const parsed = new URL(testUri);
const database = parsed.pathname.slice(1);
if (!['mongodb:', 'mongodb+srv:'].includes(parsed.protocol) || !/^signvoice_test_[a-z0-9_]+$/i.test(database)) {
  throw new Error('Refusing unsafe test database; expected signvoice_test_*');
}
parsed.pathname = `/${database}_${process.env.VITEST_POOL_ID || '1'}`;
process.env.NODE_ENV = 'test';
process.env.MONGODB_URI = parsed.toString();
process.env.JWT_ACCESS_SECRET ||= 'isolated-test-access-secret-at-least-32-chars';
process.env.JWT_REFRESH_SECRET ||= 'isolated-test-refresh-secret-at-least-32-chars';
