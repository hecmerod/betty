use crate::config::{get_backend_url, get_environment};
use axum::body::Body;
use axum::http::{HeaderMap, HeaderValue, StatusCode};
use axum::response::Response;
use tracing::{error, warn};

pub async fn check_auth(headers: &HeaderMap) -> Result<(), Response> {
    let Some(env) = get_environment() else {
        error!("ENV not set, skipping auth call");
        return Ok(());
    };

    if env == "development" {
        warn!("Development environment, skipping auth call");
        return Ok(());
    }

    let Some(base_url) = get_backend_url() else {
        warn!("BACKEND_URL not set, skipping auth call");
        return Ok(());
    };

    let auth_url = format!("{}/auth", base_url);

    let client = reqwest::Client::new();

    // Construir headers para reqwest
    let mut req_headers = reqwest::header::HeaderMap::new();

    for (name, value) in headers.iter() {
        if let (Ok(h_name), Ok(h_value)) = (
            reqwest::header::HeaderName::from_bytes(name.as_str().as_bytes()),
            reqwest::header::HeaderValue::from_bytes(value.as_bytes()),
        ) {
            req_headers.insert(h_name, h_value);
        }
    }

    // Request auth
    let resp = match client.get(auth_url).headers(req_headers).send().await {
        Ok(r) => r,
        Err(e) => {
            let mut res = Response::new(Body::from(format!("Auth request failed: {}", e)));
            *res.status_mut() = StatusCode::BAD_GATEWAY;
            res.headers_mut().insert(
                axum::http::header::CONTENT_TYPE,
                HeaderValue::from_static("text/plain"),
            );
            return Err(res);
        }
    };

    let status =
        StatusCode::from_u16(resp.status().as_u16()).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR);

    let text = match resp.text().await {
        Ok(t) => t,
        Err(e) => {
            let mut res = Response::new(Body::from(format!("Failed to read auth response: {}", e)));
            *res.status_mut() = StatusCode::INTERNAL_SERVER_ERROR;
            res.headers_mut().insert(
                axum::http::header::CONTENT_TYPE,
                HeaderValue::from_static("text/plain"),
            );
            return Err(res);
        }
    };

    let allowed = match serde_json::from_str::<bool>(&text) {
        Ok(b) => b,
        Err(_) => text.trim().eq_ignore_ascii_case("true"),
    };

    if !allowed {
        let mut res = Response::new(Body::from(text));
        *res.status_mut() = status;
        res.headers_mut().insert(
            axum::http::header::CONTENT_TYPE,
            HeaderValue::from_static("text/plain"),
        );
        return Err(res);
    }

    Ok(())
}
