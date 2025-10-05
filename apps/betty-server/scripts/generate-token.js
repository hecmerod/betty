const jwt = require('jsonwebtoken');
const fs = require('fs');
const path = require('path');

// Leer variables de entorno desde .env
const envPath = path.join(__dirname, '..', '.env');
const envContent = fs.readFileSync(envPath, 'utf8');
const envVariables = {};

envContent.split('\n').forEach((line) => {
  const [key, ...valueParts] = line.split('=');
  if (key && valueParts.length) {
    envVariables[key.trim()] = valueParts.join('=').trim();
  }
});

const secret = envVariables.JWT_SECRET || 'betty-secret-key-2024-fallback';
const expiresIn = envVariables.JWT_EXPIRES_IN || '24h';

const payload = {
  userId: 1,
  username: 'betty-user',
  deviceId: 'raspberry-pi-001',
};

const token = jwt.sign(payload, secret, { expiresIn });

console.log('🔑 JWT Token Generated');
console.log('Secret used:', secret.substring(0, 10) + '...');
console.log('Expires in:', expiresIn);
console.log('\n📋 JWT Token:');
console.log(token);
console.log('\n🧪 Curl command to test:');
console.log(
  `curl -X GET http://localhost:3000/api/protected -H "Authorization: Bearer ${token}"`
);
