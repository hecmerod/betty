use tracing::{error, info, warn};

use crate::config::get_backend_url;

pub fn activate_alarm() {
    warn!("Person detected.");
    let Some(base_url) = get_backend_url() else {
        error!("BACKEND_URL not set, skipping alarm call");
        return;
    };

    let alarm_url = format!("{}/alarm/trigger", base_url);

    match reqwest::blocking::Client::new().post(&alarm_url).send() {
        Ok(response) => {
            let status = response.status();
            let body = response.text().unwrap_or_else(|_| "<no body>".to_string());
            info!("alarm response: {} - {}", status, body);
        }
        Err(err) => {
            error!("failed to send alarm: {}", err);
        }
    }
}
