import { randomBytes } from 'crypto';
import { User, AccountStatus, AccountType } from '../models/User.model';
import { AuthSession } from '../models/AuthSession.model';
import { AuditLog, AuditAction, AuditSeverity } from '../models/AuditLog.model';
import { hashPassword } from '../utils/password.util';
import { hashToken } from '../utils/jwt.util';
import { AppError } from '../common/errors/AppError';
import { ErrorCodes } from '../common/errors/errorCodes';
import { assertMailConfigured, sendPasswordResetEmail } from './mail.service';

const eligibleAccount = { accountType: AccountType.LOCAL, isGuest: false, status: AccountStatus.ACTIVE };

export async function requestPasswordReset(email: string): Promise<void> {
  // Check availability for all addresses, without disclosing registered accounts.
  assertMailConfigured();
  const now = new Date();
  const token = randomBytes(32).toString('hex');
  const tokenHash = hashToken(token);
  const user = await User.findOneAndUpdate({
    ...eligibleAccount,
    email: email.toLowerCase().trim(),
    $or: [
      { passwordResetRequestedAt: { $exists: false } },
      { passwordResetRequestedAt: { $lte: new Date(now.getTime() - 60000) } },
    ],
  }, { $set: {
    passwordResetTokenHash: tokenHash,
    passwordResetExpiresAt: new Date(now.getTime() + 15 * 60000),
    passwordResetRequestedAt: now,
  } });
  if (!user?.email) return;
  try {
    await sendPasswordResetEmail(user.email, token);
  } catch {
    // Remove only this failed request; do not remove a newer token or log secrets.
    await User.updateOne({ _id: user._id, passwordResetTokenHash: tokenHash }, {
      $unset: { passwordResetTokenHash: 1, passwordResetExpiresAt: 1, passwordResetRequestedAt: 1 },
    });
    console.error('Password reset email delivery failed; check SMTP configuration.');
    // Keep the same public response as for an unknown account.
  }
}

export async function resetPassword(token: string, newPassword: string): Promise<void> {
  const filter = {
    ...eligibleAccount,
    passwordResetTokenHash: hashToken(token),
    passwordResetExpiresAt: { $gt: new Date() },
  };
  const invalid = () => new AppError('Liên kết không hợp lệ hoặc đã hết hạn. Vui lòng yêu cầu liên kết mới.', 400, ErrorCodes.AUTH_TOKEN_INVALID);
  if (!await User.exists(filter)) throw invalid();
  const passwordHash = await hashPassword(newPassword);
  // Update the password and consume the token in one atomic document operation.
  const user = await User.findOneAndUpdate({ ...filter, passwordResetExpiresAt: { $gt: new Date() } }, {
    $set: { passwordHash },
    $inc: { passwordVersion: 1 },
    $unset: { passwordResetTokenHash: 1, passwordResetExpiresAt: 1 },
  }, { new: true });
  if (!user) throw invalid();
  // passwordVersion also rejects sessions issued concurrently or if revocation fails.
  await AuthSession.revokeAllForUser(user._id);
  await AuditLog.log({ userId: user._id, actorRole: user.role, action: AuditAction.PASSWORD_RESET, severity: AuditSeverity.INFO });
}
