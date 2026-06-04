use v4l::buffer::Type;
use v4l::io::mmap::Stream;
use v4l::io::traits::CaptureStream;
use v4l::prelude::*;
use v4l::video::Capture;

pub struct CameraAdapter {
    device_path: String,
}

impl CameraAdapter {
    pub fn new(device_path: String) -> Self {
        CameraAdapter { device_path }
    }

    pub fn open_device(&self) -> Result<Device, String> {
        Device::with_path(&self.device_path)
            .map_err(|e| format!("open device: {}", e))
    }

    pub fn open_stream(dev: &Device) -> Result<Stream<'_>, String> {
        Stream::new(dev, Type::VideoCapture)
            .map_err(|e| format!("open stream: {}", e))
    }

    pub fn get_format(dev: &Device) -> Result<(u32, u32, String), String> {
        let fmt = dev
            .format()
            .map_err(|e| format!("query format: {}", e))?;
        Ok((fmt.width, fmt.height, format!("{}", fmt.fourcc)))
    }

    pub fn capture_frame(stream: &mut Stream) -> Result<Vec<u8>, String> {
        let (data, _meta) = stream
            .next()
            .map_err(|e| format!("capture frame: {}", e))?;
        Ok(data.to_vec())
    }
}
