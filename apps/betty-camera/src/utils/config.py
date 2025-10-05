"""
Configuración de la aplicación Betty Camera
"""

import yaml
from pathlib import Path
from typing import Dict, Any, Optional
import logging


class CameraConfig:
    """Gestión de configuración de la cámara."""
    
    def __init__(self, config_path: Optional[str] = None):
        self.config_path = Path(config_path) if config_path else Path(__file__).parent.parent / "config" / "camera.yaml"
        self.config = self._load_config()
    
    def _load_config(self) -> Dict[str, Any]:
        """Cargar configuración desde archivo YAML."""
        default_config = {
            "camera": {
                "photo_resolution": [1920, 1080],
                "video_resolution": [1280, 720],
                "photo_quality": 85,
                "video_bitrate": 10000000,
                "fps": 30
            },
            "server": {
                "host": "0.0.0.0",
                "port": 8001,
                "debug": False,
                "output_dir": "output"
            },
            "logging": {
                "level": "INFO",
                "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
            }
        }
        
        if self.config_path.exists():
            try:
                with open(self.config_path, 'r') as f:
                    loaded_config = yaml.safe_load(f)
                    # Fusionar con configuración por defecto
                    return self._merge_configs(default_config, loaded_config)
            except Exception as e:
                logging.warning(f"Error cargando configuración: {e}. Usando configuración por defecto.")
                return default_config
        else:
            # Crear archivo de configuración por defecto
            self._create_default_config(default_config)
            return default_config
    
    def _merge_configs(self, default: Dict[str, Any], loaded: Dict[str, Any]) -> Dict[str, Any]:
        """Fusionar configuraciones recursivamente."""
        result = default.copy()
        
        for key, value in loaded.items():
            if isinstance(value, dict) and key in result and isinstance(result[key], dict):
                result[key] = self._merge_configs(result[key], value)
            else:
                result[key] = value
        
        return result
    
    def _create_default_config(self, config: Dict[str, Any]):
        """Crear archivo de configuración por defecto."""
        try:
            self.config_path.parent.mkdir(parents=True, exist_ok=True)
            with open(self.config_path, 'w') as f:
                yaml.dump(config, f, default_flow_style=False, indent=2)
            logging.info(f"Archivo de configuración creado: {self.config_path}")
        except Exception as e:
            logging.warning(f"No se pudo crear archivo de configuración: {e}")
    
    def get(self, key: str, default=None):
        """Obtener valor de configuración usando notación de puntos."""
        keys = key.split('.')
        value = self.config
        
        try:
            for k in keys:
                value = value[k]
            return value
        except (KeyError, TypeError):
            return default
    
    def get_camera_config(self) -> Dict[str, Any]:
        """Obtener configuración específica de la cámara."""
        return self.config.get("camera", {})
    
    def get_server_config(self) -> Dict[str, Any]:
        """Obtener configuración del servidor."""
        return self.config.get("server", {})
    
    def get_logging_config(self) -> Dict[str, Any]:
        """Obtener configuración de logging."""
        return self.config.get("logging", {})
    
    def save(self):
        """Guardar configuración actual al archivo."""
        try:
            with open(self.config_path, 'w') as f:
                yaml.dump(self.config, f, default_flow_style=False, indent=2)
            logging.info("Configuración guardada correctamente")
        except Exception as e:
            logging.error(f"Error guardando configuración: {e}")
    
    def update(self, key: str, value: Any):
        """Actualizar valor de configuración."""
        keys = key.split('.')
        config = self.config
        
        # Navegar hasta el penúltimo nivel
        for k in keys[:-1]:
            if k not in config:
                config[k] = {}
            config = config[k]
        
        # Actualizar el valor final
        config[keys[-1]] = value
        logging.info(f"Configuración actualizada: {key} = {value}")


# Instancia global de configuración
config_instance: Optional[CameraConfig] = None


def get_config(config_path: Optional[str] = None) -> CameraConfig:
    """Obtener instancia de configuración (singleton)."""
    global config_instance
    
    if config_instance is None:
        config_instance = CameraConfig(config_path)
    
    return config_instance


def setup_logging(config: CameraConfig):
    """Configurar logging basado en la configuración."""
    logging_config = config.get_logging_config()
    
    level = getattr(logging, logging_config.get("level", "INFO").upper())
    format_str = logging_config.get("format", "%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    
    logging.basicConfig(
        level=level,
        format=format_str,
        handlers=[
            logging.StreamHandler(),
        ]
    )
    
    # Configurar logger específico para la aplicación
    logger = logging.getLogger("betty_camera")
    logger.setLevel(level)
    
    return logger