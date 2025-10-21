import requests
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
from logger import get_logger
from domain.models.alarm import Alarm
from infrastructure.adapters.betty_server_adapter import BettyServerAdapter


class AlarmAdapter:
    def __init__(self, betty_server_adapter: BettyServerAdapter):
        self.logger = get_logger()
        self.betty_server = betty_server_adapter
    
    def trigger_alarm(self, alarm: Alarm) -> bool:
        try:
            url = f"{self.betty_server.base_url}/alarm/trigger"
            token = self.betty_server._get_valid_token()
            
            headers = {
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json'
            }
            
            response = requests.post(
                url,
                headers=headers,
                json=alarm.to_dict(),
                timeout=self.betty_server.timeout
            )
            
            if response.status_code in [200, 201]:
                self.logger.info("✅ Alarma enviada correctamente")
                return True
            else:
                self.logger.error(f"❌ Error enviando alarma: {response.status_code}")
                return False
                
        except requests.exceptions.Timeout:
            self.logger.error("⏰ Timeout enviando alarma")
            return False
        except requests.exceptions.ConnectionError:
            self.logger.error("🔌 Error de conexión con betty-server")
            return False
        except Exception as e:
            self.logger.error(f"❌ Error enviando alarma: {e}")
            return False
