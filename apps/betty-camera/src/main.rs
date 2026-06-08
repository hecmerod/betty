use axum::routing::get;
use axum::Router;
use std::net::SocketAddr;
use std::sync::Arc;

mod camera;
mod capture_process;
mod config;
mod detection;
mod http;
mod image_processor;
mod routes;
mod state;

use camera::CameraAdapter;
use capture_process::start_capture_process;
use routes::camera::stream_handler;
use routes::health;
use routes::root;
use state::CameraState;

#[tokio::main]
async fn main() {
    dotenvy::dotenv().ok();
    tracing_subscriber::fmt().without_time().init();

    let port = std::env::var("PORT")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(8001);

    let camera_adapter = Arc::new(CameraAdapter::new());
    let frame_rx = start_capture_process(camera_adapter.clone());
    let camera_state = CameraState { frame_rx };

    let app = Router::new()
        .route("/", get(root::handler))
        .route("/camera", get(stream_handler))
        .route("/health", get(health::handler))
        .with_state(camera_state);

    let addr = SocketAddr::from(([0, 0, 0, 0], port));

    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .expect("bind address");

    axum::serve(listener, app).await.expect("server failure");
}
