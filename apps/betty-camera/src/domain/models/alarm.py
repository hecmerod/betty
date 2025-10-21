from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class Alarm:
    source: str
    event_type: str
    timestamp: float
    metadata: Optional[dict] = None
    
    def to_dict(self):
        return {
            'source': self.source,
            'event_type': self.event_type,
            'timestamp': self.timestamp,
            'metadata': self.metadata or {}
        }
