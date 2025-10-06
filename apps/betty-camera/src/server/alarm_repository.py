"""
Alarm Repository - Manejo de todas las operaciones relacionadas con alarmas
"""

import time
from typing import Dict, Any
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from logger import get_logger
from server.betty_server_client import get_betty_client


class AlarmRepository:    
    def __init__(self):
        self.logger = get_logger()
        self.betty_client = get_betty_client()
    
    def trigger_alarm(self) -> bool:
        try:
            alarm_payload = {
                'source': 'betty-camera',
                'event_type': 'person_detected',
                'timestamp': time.time(),
            }
            
            result = self.betty_client._make_authenticated_request('POST', 'alarm/trigger', alarm_payload)
            print(result)
        except Exception as e:
            self.logger.error(f"❌ Error enviando alarma a betty-server: {e}")
            return False

_alarm_repository = None

def get_alarm_repository() -> AlarmRepository:
    """Obtiene la instancia global del repositorio de alarmas."""
    global _alarm_repository
    if _alarm_repository is None:
        _alarm_repository = AlarmRepository()
    return _alarm_repository