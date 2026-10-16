import { Request, Response, NextFunction } from 'express';
import { oauthAvailability, oauthConfig, providerName } from '../config/oauth';
import { beginOAuth, consumeState, resolveOAuthUser } from '../services/oauth.service';
import { exchangeIdentity } from '../services/oauth-provider.service';
import { loginOAuthUser, refreshTokens } from '../services/auth.service';
import { setRefreshCookie } from './auth.controller';
import { AppError } from '../common/errors/AppError';
import { User } from '../models/User.model';
import { verifyAccessToken } from '../utils/jwt.util';
import { authorizationFor } from '../services/authorization.service';
import { env } from '../config/env';

export function providers(_req: Request, res: Response) {
  res.setHeader('Cache-Control', 'no-store');
  res.json({ success: true, data: oauthAvailability() });
}
export async function start(req: Request, res: Response, next: NextFunction) {
  try {
    const provider = providerName(req.params.provider);
    const config = oauthConfig(provider);
    const result = await beginOAuth(provider, config);
    res.setHeader('Cache-Control', 'no-store');
    res.cookie(`signvoice_oauth_${provider}`, result.browser, { httpOnly: true, secure: config.secure,
      sameSite: 'lax', maxAge: config.ttl * 1000, path: `/api/v1/auth/oauth/${provider}` });
    res.redirect(302, result.url);
  } catch (error) { next(error); }
}
export async function callback(req: Request, res: Response, next: NextFunction) {
  let destination: string | undefined;
  try {
    const provider = providerName(req.params.provider);
    const config = oauthConfig(provider);
    destination = config.completion;
    const record = await consumeState(provider, config, req.query.state, req.cookies?.[`signvoice_oauth_${provider}`]);
    res.clearCookie(`signvoice_oauth_${provider}`, { httpOnly: true, secure: config.secure,
      sameSite: 'lax', path: `/api/v1/auth/oauth/${provider}` });
    // Consume state even on denial: cancellation cannot be replayed as success.
    if (req.query.error) throw new AppError('Đã hủy đăng nhập.', 400, 'OAUTH_CANCELLED');
    if (typeof req.query.code !== 'string' || !req.query.code || req.query.code.length > 4096)
      throw new AppError('Missing OAuth code', 400, 'OAUTH_CODE_INVALID');
    const identity = await exchangeIdentity(provider, config, req.query.code, record.nonce, record.verifier);
    const user = await resolveOAuthUser(provider, identity);
    const result = await loginOAuthUser(user, { ipAddress: req.socket.remoteAddress, userAgent: req.get('user-agent') });
    setRefreshCookie(res, result.tokens, config.secure);
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('Referrer-Policy', 'no-referrer');
    res.redirect(303, destination);
  } catch (error) {
    if (!destination) { next(error); return; }
    const known = ['OAUTH_CANCELLED', 'OAUTH_STATE_INVALID', 'OAUTH_CODE_INVALID', 'OAUTH_IDENTITY_INVALID', 'OAUTH_ACCOUNT_COLLISION', 'USER_DISABLED'];
    const code = error instanceof AppError && known.includes(error.code) ? error.code : 'OAUTH_FAILED';
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('Referrer-Policy', 'no-referrer');
    res.redirect(303, `${destination}?error=${code}`);
  }
}
export async function complete(req: Request, res: Response, next: NextFunction) {
  try {
    // Cookie authorization always requires a configured frontend Origin, even without credentials.
    const origin = req.get('origin');
    if (!origin || origin !== env.OAUTH_FRONTEND_ORIGIN || !env.CORS_ALLOWED_ORIGINS.includes(origin))
      throw new AppError('Untrusted OAuth completion origin', 403, 'OAUTH_ORIGIN_INVALID');
    const token = req.cookies?.signvoice_refresh;
    if (typeof token !== 'string') throw new AppError('Không tìm thấy phiên đăng nhập OAuth.', 401, 'OAUTH_SESSION_MISSING');
    const tokens = await refreshTokens(token, { ipAddress: req.socket.remoteAddress, userAgent: req.get('user-agent') });
    const user = await User.findById(verifyAccessToken(tokens.accessToken).userId);
    if (!user || !user.isActive()) throw new AppError('Account unavailable', 401, 'OAUTH_SESSION_MISSING');
    // Derive cookie security from explicit config, never proxy headers.
    setRefreshCookie(res, tokens, env.OAUTH_BACKEND_ORIGIN.startsWith('https://'));
    res.setHeader('Cache-Control', 'no-store');
    res.json({ success: true, data: { user: { id: user._id.toString(), email: user.email,
      displayName: user.displayName, avatarUrl: user.avatarUrl, isGuest: user.isGuest,
      accountType: user.accountType, status: user.status, createdAt: user.createdAt,
      updatedAt: user.updatedAt, ...await authorizationFor(user) }, tokens } });
  } catch (error) { next(error); }
}
