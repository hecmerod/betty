use std::path::Path;
use std::sync::Arc;

use image::imageops::FilterType;
use ndarray::{s, Array4, Axis};
use tract_onnx::prelude::*;

pub struct DetectionModel {
    model: Arc<RunnableModel<TypedFact, Box<dyn TypedOp>>>,
}

impl DetectionModel {
    pub fn new(model_path: impl AsRef<Path>) -> Result<Self, String> {
        let model = tract_onnx::onnx()
            .model_for_path(model_path.as_ref())
            .map_err(|e| format!("load model: {}", e))?
            .with_input_fact(
                0,
                InferenceFact::dt_shape(f32::datum_type(), tvec!(1, 3, 640, 640)),
            )
            .map_err(|e| format!("set input fact: {}", e))?
            .into_optimized()
            .map_err(|e| format!("optimize model: {}", e))?
            .into_runnable()
            .map_err(|e| format!("create runnable model: {}", e))?;

        Ok(DetectionModel { model })
    }

    pub fn detect_person(&self, jpeg_bytes: &[u8]) -> Result<bool, String> {
        let image = image::load_from_memory(jpeg_bytes)
            .map_err(|e| format!("decode image: {}", e))?
            .resize_exact(640, 640, FilterType::Triangle)
            .to_rgb8();

        let input = Array4::from_shape_fn((1, 3, 640, 640), |(_b, c, y, x)| {
            let pixel = image.get_pixel(x as u32, y as u32);
            pixel[c] as f32 / 255.0
        });

        let input_tensor = Tensor::from(input);
        let outputs = self
            .model
            .run(tvec!(input_tensor.into_tvalue()))
            .map_err(|e| format!("run model: {}", e))?;

        let output = outputs
            .get(0)
            .ok_or_else(|| "model returned no outputs".to_string())?
            .to_plain_array_view::<f32>()
            .map_err(|e| format!("output as array: {}", e))?;

        let output = output
            .into_dimensionality::<ndarray::Ix3>()
            .map_err(|e| format!("unexpected output shape: {}", e))?;

        let shape = output.shape();
        if shape.len() != 3 || shape[0] != 1 {
            return Err(format!("unexpected output shape: {:?}", shape));
        }

        let (num_channels, num_boxes, is_transposed) = if shape[1] == 84 || shape[1] == 85 {
            (shape[1], shape[2], true)
        } else if shape[2] == 84 || shape[2] == 85 {
            (shape[2], shape[1], false)
        } else {
            return Err(format!("unexpected output shape: {:?}", shape));
        };

        let class_offset = if num_channels == 84 { 4 } else { 5 };
        let class_count = num_channels - class_offset;
        let threshold = 0.5;
        let mut found_person = false;

        if is_transposed {
            let detections = output.index_axis(Axis(0), 0);
            for i in 0..num_boxes {
                let _cx = detections[[0, i]];
                let _cy = detections[[1, i]];
                let _w = detections[[2, i]];
                let _h = detections[[3, i]];

                let mut max_score = 0.0f32;
                let mut max_class_id = 0usize;
                for class_id in 0..class_count {
                    let score = detections[[class_offset + class_id, i]];
                    if score > max_score {
                        max_score = score;
                        max_class_id = class_id;
                    }
                }

                if max_class_id == 0 && max_score > threshold {
                    found_person = true;
                    break;
                }
            }
        } else {
            let detections = output.index_axis(Axis(0), 0);
            for row in detections.outer_iter() {
                if row.len() <= class_offset {
                    continue;
                }

                let class_scores = row.slice(s![class_offset..]);
                let (class_id, class_conf) = class_scores
                    .iter()
                    .enumerate()
                    .fold((0usize, 0.0f32), |best, (idx, score)| {
                        if *score > best.1 {
                            (idx, *score)
                        } else {
                            best
                        }
                    });

                if class_id == 0 && class_conf > threshold {
                    found_person = true;
                    break;
                }
            }
        }

        Ok(found_person)
    }
}
