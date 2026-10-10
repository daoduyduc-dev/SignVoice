#!/usr/bin/env tsx
/**
 * Validate OpenAPI specification
 */
import { validateOpenApiSpec } from '../src/config/swagger';

console.log('🔍 Validating OpenAPI specification...\n');

const isValid = validateOpenApiSpec();

if (isValid) {
  console.log('\n✅ OpenAPI specification is valid');
  process.exit(0);
} else {
  console.log('\n❌ OpenAPI specification validation failed');
  process.exit(1);
}
