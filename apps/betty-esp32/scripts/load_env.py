Import("env")

from pathlib import Path

ENV_KEYS = ("WIFI_SSID", "WIFI_PASSWORD", "JWT_SECRET", "SERVER_URL")


def load_dotenv(path):
    values = {}
    if not path.exists():
        return values

    for raw in path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1]
        values[key] = value
    return values


project_dir = Path(env.subst("$PROJECT_DIR"))
dotenv = load_dotenv(project_dir / ".env")

missing = [key for key in ENV_KEYS if not dotenv.get(key)]
if missing:
    raise SystemExit(
        "Missing "
        + ", ".join(missing)
        + " in .env. Copy .env.example to .env and fill in values."
    )

def c_string(value):
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


config_h = project_dir / "include" / "config.h"
config_h.parent.mkdir(parents=True, exist_ok=True)
config_h.write_text(
    "\n".join(
        [
            "#ifndef CONFIG_H",
            "#define CONFIG_H",
            "",
            *(f"#define {key} {c_string(dotenv[key])}" for key in ENV_KEYS),
            "",
            "#endif",
            "",
        ]
    )
)
