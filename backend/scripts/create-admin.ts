#!/usr/bin/env tsx
/**
 * Create ADMIN account for testing
 */
import { connectDatabase } from '../src/config/database';
import { User } from '../src/models/User.model';
import * as argon2 from 'argon2';

async function createAdmin() {
  console.log('🔧 Creating ADMIN account...\n');

  try {
    // Connect to database
    await connectDatabase();
    console.log('✅ Connected to MongoDB\n');

    // Check if admin already exists
    const existingAdmin = await User.findOne({ 
      email: 'admin@signvoice.com' 
    });

    if (existingAdmin) {
      console.log('⚠️  ADMIN account already exists!');
      console.log('\nCredentials:');
      console.log('  Email:    admin@signvoice.com');
      console.log('  Password: Admin123!');
      console.log('  Role:     ADMIN');
      console.log('  Status:   ' + existingAdmin.status);
      console.log('\nYou can use this account to login.\n');
      process.exit(0);
    }

    // Hash password
    const password = 'Admin123!';
    const passwordHash = await argon2.hash(password);

    // Create ADMIN user
    const admin = await User.create({
      email: 'admin@signvoice.com',
      passwordHash,
      displayName: 'System Administrator',
      role: 'ADMIN',
      status: 'ACTIVE',
      accountType: 'LOCAL',
      isGuest: false,
    });

    console.log('✅ ADMIN account created successfully!\n');
    console.log('Credentials:');
    console.log('  Email:    admin@signvoice.com');
    console.log('  Password: Admin123!');
    console.log('  Role:     ADMIN');
    console.log('  ID:       ' + admin._id);
    console.log('\n⚠️  IMPORTANT: Change password after first login!');
    console.log('\nYou can now:');
    console.log('  1. Open http://localhost:3000/api-docs');
    console.log('  2. POST /api/v1/auth/login with above credentials');
    console.log('  3. Copy accessToken');
    console.log('  4. Click "Authorize" and paste token');
    console.log('  5. Test ADMIN endpoints\n');

  } catch (error) {
    console.error('❌ Error creating ADMIN account:', error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

// Run
createAdmin();
