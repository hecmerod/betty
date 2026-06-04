use std::sync::Arc;
use std::time::Duration;
use tokio::sync::watch;
use tokio::task;
use bytes::Bytes;

use crate::camera::CameraAdapter;
use crate::image_processor::ImageProcessor;

pub fn start_capture_process(
    adapter: Arc<CameraAdapter>,
) -> watch::Receiver<Option<Bytes>> {
    let (frame_tx, frame_rx) = watch::channel(None);

    tokio::spawn(async move {
        let result = task::spawn_blocking(move || {
            let dev = adapter.open_device()?;
            let mut stream = CameraAdapter::open_stream(&dev)?;
            let (width, height, fourcc_str) = CameraAdapter::get_format(&dev)?;

            eprintln!("Capture process started: {}x{} format={}", width, height, fourcc_str);

            loop {
                let data = CameraAdapter::capture_frame(&mut stream)?;
                let image = ImageProcessor::process_frame(data, width, height, &fourcc_str)?;

                if frame_tx.send(Some(image)).is_err() {
                    eprintln!("Capture process sender closed, shutting down");
                    break;
                }

                std::thread::sleep(Duration::from_millis(50));
            }

            Ok::<(), String>(())
        })
        .await;

        if let Err(err) = result {
            eprintln!("Capture process error: {}", err);
        }
    });

    frame_rx
}
