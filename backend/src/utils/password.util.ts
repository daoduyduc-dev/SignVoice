import argon2 from 'argon2';

/**
 * Hash password using Argon2id (industry standard, resistant to GPU attacks)
 */
export async function hashPassword(password: string): Promise<string> {
  return await argon2.hash(password, {
    type: argon2.argon2id,
    memoryCost: 65536, // 64 MB
    timeCost: 3,
    parallelism: 4,
  });
}

/**
 * Verify password against hash
 */
export async function verifyPassword(hash: string, password: string): Promise<boolean> {
  try {
    return await argon2.verify(hash, password);
  } catch (error) {
    // Invalid hash format or verification failed
    return false;
  }
}

/**
 * Check if hash needs rehashing (if algorithm params changed)
 */
export async function needsRehash(hash: string): Promise<boolean> {
  try {
    return argon2.needsRehash(hash, {
      type: argon2.argon2id,
      memoryCost: 65536,
      timeCost: 3,
      parallelism: 4,
    });
  } catch (error) {
    return true; // Rehash if we can't determine
  }
}
