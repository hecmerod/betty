use bytes::Bytes;
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};
use tokio::sync::watch;
use tokio::task;
use tracing::{error, info};

use crate::camera::CameraAdapter;
use crate::detection::DetectionModel;
use crate::http::alarm::activate_alarm;
use crate::image_processor::ImageProcessor;

pub fn start_capture_process(adapter: Arc<CameraAdapter>) -> watch::Receiver<Option<Bytes>> {
    let (frame_tx, frame_rx) = watch::channel(None);

    let model_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join(std::env::var("MODEL_PATH").expect("MODEL_PATH not set"));
    let detection_model = match DetectionModel::new(&model_path) {
        Ok(model) => Some(Arc::new(Mutex::new(model))),
        Err(err) => {
            error!("load detection model: {}", err);
            None
        }
    };

    tokio::spawn(async move {
        let result = task::spawn_blocking(move || {
            let dev = adapter.open_device()?;
            let mut stream = CameraAdapter::open_stream(&dev)?;
            let (width, height, fourcc_str) = CameraAdapter::get_format(&dev)?;

            info!(
                "Capture process started: {}x{} format={}",
                width, height, fourcc_str
            );
            let mut next_detection = Instant::now() + Duration::from_secs(1);

            loop {
                let data = CameraAdapter::capture_frame(&mut stream)?;
                let image = ImageProcessor::process_frame(data, width, height, &fourcc_str)?;

                if frame_tx.send(Some(image.clone())).is_err() {
                    break;
                }

                if let Some(model) = detection_model.clone() {
                    if Instant::now() >= next_detection {
                        let image_for_detection = image.clone();
                        std::thread::spawn(move || {
                            let model = model.lock().unwrap();
                            match model.detect_person(&image_for_detection) {
                                Ok(true) => activate_alarm(),
                                Ok(false) => {}
                                Err(err) => error!("detection error: {}", err),
                            }
                        });
                        next_detection += Duration::from_secs(5);
                    }
                }

                std::thread::sleep(Duration::from_millis(50));
            }

            Ok::<(), String>(())
        })
        .await;

        if let Err(err) = result {
            error!("Capture process error: {}", err);
        }
    });

    frame_rx
}
