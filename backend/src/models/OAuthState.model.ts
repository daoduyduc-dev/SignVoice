import { Schema, model } from 'mongoose';

const schema = new Schema({
  stateHash: { type: String, required: true, unique: true },
  browserHash: { type: String, required: true },
  provider: { type: String, enum: ['google', 'facebook'], required: true },
  callback: { type: String, required: true },
  completion: { type: String, required: true },
  nonce: { type: String, required: true },
  verifier: { type: String, required: true },
  expiresAt: { type: Date, required: true },
});
schema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
export const OAuthState = model('OAuthState', schema);
