import { env } from './env';
import { AppError } from '../common/errors/AppError';

export type OAuthProvider = 'google' | 'facebook';
export function providerName(value: string): OAuthProvider {
  if (value !== 'google' && value !== 'facebook') throw new AppError('Unknown OAuth provider', 404, 'OAUTH_PROVIDER_UNKNOWN');
  return value;
}
function safeUrl(value: string): URL {
  const url = new URL(value);
  const local = ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname);
  if (url.username || url.password || url.search || url.hash ||
    !(url.protocol === 'https:' || (env.NODE_ENV !== 'production' && local && url.protocol === 'http:'))) throw new Error('Invalid OAuth URL');
  return url;
}
export function oauthConfig(provider: OAuthProvider) {
  const clientId = provider === 'google' ? env.GOOGLE_CLIENT_ID : env.FACEBOOK_APP_ID;
  const clientSecret = provider === 'google' ? env.GOOGLE_CLIENT_SECRET : env.FACEBOOK_APP_SECRET;
  if (!clientId || !clientSecret) throw new AppError('OAuth chưa được cấu hình trên máy chủ.', 503, 'OAUTH_DISABLED');
  try {
    const backend = safeUrl(env.OAUTH_BACKEND_ORIGIN);
    const frontend = safeUrl(env.OAUTH_FRONTEND_ORIGIN);
    if (env.OAUTH_BACKEND_ORIGIN !== backend.origin || env.OAUTH_FRONTEND_ORIGIN !== frontend.origin)
      throw new Error('Origins must be exact, without path or trailing slash');
    if (backend.hostname !== frontend.hostname || backend.protocol !== frontend.protocol ||
        (backend.protocol === 'https:' && backend.origin !== frontend.origin)) throw new Error('Web and API must share the cookie site');
    const path = `/api/v1/auth/oauth/${provider}/callback`;
    const override = provider === 'google' ? env.GOOGLE_CALLBACK_URL : env.FACEBOOK_CALLBACK_URL;
    const callback = safeUrl(override || `${backend.origin}${path}`);
    if (callback.origin !== backend.origin || callback.pathname !== path) throw new Error('Callback mismatch');
    if (!Number.isInteger(env.OAUTH_STATE_TTL_SECONDS) || env.OAUTH_STATE_TTL_SECONDS < 60 || env.OAUTH_STATE_TTL_SECONDS > 900) throw new Error('State lifetime must be 60–900 seconds');
    if (provider === 'facebook' && !/^v\d+\.\d+$/.test(env.FACEBOOK_GRAPH_API_VERSION)) throw new Error('Missing Graph API version');
    return { clientId, clientSecret, callback: callback.href, frontend: frontend.origin,
      completion: `${frontend.origin}/#/oauth-complete`, secure: backend.protocol === 'https:',
      ttl: env.OAUTH_STATE_TTL_SECONDS, graphVersion: env.FACEBOOK_GRAPH_API_VERSION };
  } catch {
    throw new AppError('Cấu hình OAuth không hợp lệ. Kiểm tra origin, callback, TTL và phiên bản Graph API.', 503, 'OAUTH_CONFIGURATION_INVALID');
  }
}
export function oauthAvailability(): Record<OAuthProvider, boolean> {
  const enabled = (p: OAuthProvider) => { try { oauthConfig(p); return true; } catch { return false; } };
  return { google: enabled('google'), facebook: enabled('facebook') };
}
