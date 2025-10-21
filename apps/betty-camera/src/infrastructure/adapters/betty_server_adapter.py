import os
import time
import jwt
from typing import Optional
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
from logger import get_logger


class BettyServerAdapter:
    def __init__(self, base_url: str, token: Optional[str] = None):
        self.logger = get_logger()
        self.base_url = base_url.rstrip('/')
        self.jwt_secret = os.getenv('JWT_SECRET')
        self.timeout = 5
        
        self._cached_token = None
        self._token_expiry = 0
    
    def _generate_jwt_token(self) -> str:
        try:
            payload = {
                'userId': 1,
                'username': 'betty-camera',
                'deviceId': 'raspberry-pi-camera',
                'iat': int(time.time()),
                'exp': int(time.time()) + (24 * 60 * 60)
            }
            
            token = jwt.encode(payload, self.jwt_secret, algorithm='HS256')
            return token
            
        except Exception as e:
            self.logger.error(f"❌ Error generando token JWT: {e}")
            raise
    
    def _get_valid_token(self) -> str:
        current_time = time.time()
        
        if not self._cached_token or current_time >= (self._token_expiry - 300):
            self._cached_token = self._generate_jwt_token()
            self._token_expiry = current_time + (24 * 60 * 60)
        
        return self._cached_token
