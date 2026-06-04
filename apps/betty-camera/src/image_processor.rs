use bytes::Bytes;
use image::codecs::jpeg::JpegEncoder;
use image::ColorType;

pub struct ImageProcessor;

impl ImageProcessor {
    pub fn process_frame(
        data: Vec<u8>,
        width: u32,
        height: u32,
        fourcc_str: &str,
    ) -> Result<Bytes, String> {
        if fourcc_str == "MJPG" {
            return Ok(Bytes::from(data));
        }

        let rgb = match fourcc_str {
            "YUYV" => Self::yuyv_to_rgb(&data, width, height)?,
            "UYVY" => Self::uyvy_to_rgb(&data, width, height)?,
            _ => {
                return Err(format!("unsupported pixel format: {}", fourcc_str));
            }
        };

        let jpeg = Self::encode_jpeg(&rgb, width, height)?;
        Ok(Bytes::from(jpeg))
    }

    fn yuyv_to_rgb(data: &[u8], width: u32, height: u32) -> Result<Vec<u8>, String> {
        Self::convert_yuv_to_rgb(data, width, height, false)
    }

    fn uyvy_to_rgb(data: &[u8], width: u32, height: u32) -> Result<Vec<u8>, String> {
        Self::convert_yuv_to_rgb(data, width, height, true)
    }

    fn convert_yuv_to_rgb(
        data: &[u8],
        width: u32,
        height: u32,
        uyvy: bool,
    ) -> Result<Vec<u8>, String> {
        let expected = (width * height * 2) as usize;
        if data.len() < expected {
            return Err(format!(
                "frame size mismatch: got {} bytes, expected {}",
                data.len(),
                expected
            ));
        }

        let mut rgb = Vec::with_capacity((width * height * 3) as usize);
        for chunk in data.chunks_exact(4) {
            let (y0, u, y1, v) = if uyvy {
                (chunk[1], chunk[0], chunk[3], chunk[2])
            } else {
                (chunk[0], chunk[1], chunk[2], chunk[3])
            };

            rgb.extend_from_slice(&Self::yuv_pixel_to_rgb(y0, u, v));
            rgb.extend_from_slice(&Self::yuv_pixel_to_rgb(y1, u, v));
        }

        Ok(rgb)
    }

    fn yuv_pixel_to_rgb(y: u8, u: u8, v: u8) -> [u8; 3] {
        let c = i32::from(y).saturating_sub(16);
        let d = i32::from(u).saturating_sub(128);
        let e = i32::from(v).saturating_sub(128);
        let r = Self::clamp((298 * c + 409 * e + 128) >> 8);
        let g = Self::clamp((298 * c - 100 * d - 208 * e + 128) >> 8);
        let b = Self::clamp((298 * c + 516 * d + 128) >> 8);
        [r, g, b]
    }

    fn clamp(value: i32) -> u8 {
        value.clamp(0, 255) as u8
    }

    fn encode_jpeg(rgb: &[u8], width: u32, height: u32) -> Result<Vec<u8>, String> {
        let mut buffer = Vec::with_capacity(width as usize * height as usize);
        let mut encoder = JpegEncoder::new_with_quality(&mut buffer, 70);
        encoder
            .encode(rgb, width, height, ColorType::Rgb8)
            .map_err(|e| format!("jpeg encode: {}", e))?;
        Ok(buffer)
    }
}
