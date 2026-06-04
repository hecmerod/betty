use axum::extract::State;
use axum::http::header;
use axum::response::{IntoResponse, Response};
use axum::body::Body;
use bytes::Bytes;
use tokio::sync::watch;
use tokio_stream::{wrappers::WatchStream, StreamExt};

use crate::state::CameraState;

const BOUNDARY: &str = "frame";

pub async fn stream_handler(State(state): State<CameraState>) -> Response {
    let stream = WatchStream::new(state.frame_rx.clone())
        .map(|frame| {
            frame.map(|image| {
                let mut buffer = Vec::with_capacity(image.len() + 128);
                buffer.extend_from_slice(format!("--{}\r\nContent-Type: image/jpeg\r\nContent-Length: {}\r\n\r\n", BOUNDARY, image.len()).as_bytes());
                buffer.extend_from_slice(&image);
                buffer.extend_from_slice(b"\r\n");
                Ok::<_, std::io::Error>(Bytes::from(buffer))
            })
        })
        .filter_map(|item| item);

    (
        [
            (
                header::CONTENT_TYPE,
                format!("multipart/x-mixed-replace; boundary={}", BOUNDARY),
            ),
            (header::CACHE_CONTROL, "no-cache".to_string()),
            (header::PRAGMA, "no-cache".to_string()),
            (header::CONNECTION, "keep-alive".to_string()),
        ],
        Body::from_stream(stream),
    )
        .into_response()
}
