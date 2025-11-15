import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

@Injectable()
export class UsbCameraFinderService implements OnModuleInit {
  private readonly logger = new Logger(UsbCameraFinderService.name);
  private internalCamera: string | null = null;
  private externalCameras: string[] = [];

  async onModuleInit() {
    await this.findAllUsbCameras();

    if (!this.internalCamera) throw new Error('No internal cameras detected');
    if (this.externalCameras.length === 0)
      throw new Error('No external cameras detected');
  }

  async findAllUsbCameras(): Promise<void> {
    const { stdout } = await execAsync(
      'v4l2-ctl --list-devices 2>/dev/null || echo ""'
    );

    const cameras: string[] = [];
    const lines = stdout.split('\n');
    let isUsbCamera = false;
    let isWebcam = false;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      if (
        (line.toLowerCase().includes('usb') ||
          line.includes('HD 2MP WEBCAM') ||
          line.includes('USB Camera')) &&
        !line.toLowerCase().includes('bcm') &&
        !line.toLowerCase().includes('mmal')
      ) {
        isUsbCamera = true;
        isWebcam =
          line.toLowerCase().includes('webcam') ||
          line.includes('HD 2MP WEBCAM');
        continue;
      }

      if (isUsbCamera && line.includes('/dev/video')) {
        const match = line.match(/\/dev\/video\d+/);
        if (match && !cameras.includes(match[0])) {
          const isCapture = await this.isVideoCaptureDevice(match[0]);
          if (isCapture) {
            if (isWebcam && !this.internalCamera) {
              this.internalCamera = match[0];
            } else {
              this.externalCameras.push(match[0]);
            }
          }
        }
      }

      if (
        isUsbCamera &&
        !line.startsWith('\t') &&
        !line.startsWith(' ') &&
        line.trim()
      ) {
        isUsbCamera = false;
        isWebcam = false;
      }
    }
  }

  private async isVideoCaptureDevice(devicePath: string): Promise<boolean> {
    try {
      const { stdout } = await execAsync(
        `v4l2-ctl --device=${devicePath} --list-formats 2>/dev/null || echo ""`
      );

      const hasValidFormat =
        stdout.includes('MJPG') ||
        stdout.includes('YUYV') ||
        stdout.includes('H264') ||
        stdout.includes('RGB');

      return hasValidFormat;
    } catch {
      return false;
    }
  }

  getInternalCamera(): string | null {
    return this.internalCamera;
  }

  getExternalCameras(): string[] {
    return [...this.externalCameras];
  }

  getAvailableCameras(): string[] {
    const cameras: string[] = [];
    if (this.internalCamera) cameras.push(this.internalCamera);
    cameras.push(...this.externalCameras);
    return cameras;
  }

  async refreshCameras(): Promise<void> {
    this.internalCamera = null;
    this.externalCameras = [];
    await this.findAllUsbCameras();
  }
}
