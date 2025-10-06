"""
Betty Server Client - Cliente para comunicar con betty-server
Maneja autenticación JWT y llamadas a los endpoints REST
"""

import os
import time
import jwt
import requests
from typing import Dict, Any, Optional
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from logger import get_logger


class BettyServerClient:
    """Cliente HTTP para comunicar con betty-server con autenticación JWT."""
    
    def __init__(self):
        self.logger = get_logger()
        
        self.base_url = os.getenv('BETTY_SERVER_URL')
        self.jwt_secret = os.getenv('JWT_SECRET')
        self.jwt_expires_in = os.getenv('JWT_EXPIRES_IN')
        
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
    
    def _make_authenticated_request(self, method: str, endpoint: str, data: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        try:
            url = f"{self.base_url}/{endpoint.lstrip('/')}"
            
            token = self._get_valid_token()
            headers = {
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json'
            }
            
            if method.upper() == 'GET':
                response = requests.get(url, headers=headers, timeout=self.timeout)
            elif method.upper() == 'POST':
                response = requests.post(url, headers=headers, json=data, timeout=self.timeout)
            else:
                raise ValueError(f"Método HTTP no soportado: {method}")
            
            if response.status_code in [200, 201]:
                result = response.json() if response.content else {}
                return result
            else:
                self.logger.error(f"❌ Error en petición a {endpoint}: {response.status_code} - {response.text}")
                raise Exception(f"HTTP {response.status_code}: {response.text}")
                
        except requests.exceptions.Timeout:
            self.logger.error(f"⏰ Timeout en petición a {endpoint}")
            raise Exception(f"Timeout connecting to betty-server at {endpoint}")
        except requests.exceptions.ConnectionError:
            self.logger.error(f"🔌 Error de conexión a betty-server en {endpoint}")
            raise Exception(f"Connection error to betty-server at {endpoint}")
        except Exception as e:
            self.logger.error(f"❌ Error en petición a {endpoint}: {e}")
            raise
    



# Instancia global del cliente (singleton)
_betty_client = None

def get_betty_client() -> BettyServerClient:
    """Obtiene la instancia global del cliente Betty Server."""
    global _betty_client
    if _betty_client is None:
        _betty_client = BettyServerClient()
    return _betty_client