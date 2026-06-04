use bytes::Bytes;
use tokio::sync::watch;

#[derive(Clone)]
pub struct CameraState {
    pub frame_rx: watch::Receiver<Option<Bytes>>,
}
