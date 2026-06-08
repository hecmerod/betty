use tracing::{error, warn};

use crate::config::get_backend_url;

pub fn activate_alarm() {
    warn!("Person detected.");
    let Some(base_url) = get_backend_url() else {
        error!("BACKEND_URL not set, skipping alarm call");
        return;
    };

    let alarm_url = format!("{}/alarm/activate", base_url);

    if let Err(err) = reqwest::blocking::Client::new().post(&alarm_url).send() {
        error!("failed to send alarm: {}", err);
    }
}
