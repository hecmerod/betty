use axum::response::IntoResponse;

pub async fn handler() -> impl IntoResponse {
    "betty-camera API available: GET /camera (MJPEG stream), GET /health"
}
