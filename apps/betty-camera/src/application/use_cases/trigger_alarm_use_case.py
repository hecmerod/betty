import time
from domain.models.alarm import Alarm


class TriggerAlarmUseCase:
    def __init__(self, alarm_adapter):
        self.alarm_adapter = alarm_adapter
    
    def execute(self, event_type: str, metadata: dict = None) -> bool:
        alarm = Alarm(
            source='betty-camera',
            event_type=event_type,
            timestamp=time.time(),
            metadata=metadata
        )
        
        return self.alarm_adapter.trigger_alarm(alarm)
