const jwt = require('jsonwebtoken');

const secret = 'betty-secret-key-2024';
const payload = {
  userId: 1,
  username: 'betty-user',
  deviceId: 'raspberry-pi-001',
};

const token = jwt.sign(payload, secret, { expiresIn: '24h' });

console.log('JWT Token:');
console.log(token);
console.log('\nCurl command to test:');
console.log(
  `curl -X GET http://localhost:3000/api/protected -H "Authorization: Bearer ${token}"`
);
