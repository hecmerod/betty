import { Injectable } from '@nestjs/common';

export interface GridCameraConfig {
  devicePath: string;
  position: 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right';
}

export interface FFmpegGridConfig {
  inputs: string[];
  filterComplex: string;
  outputArgs: string[];
}

@Injectable()
export class MultiCameraGridService {
  generateGridConfig(cameras: GridCameraConfig[]): FFmpegGridConfig {
    const inputs: string[] = [];
    const filterInputs: string[] = [];

    cameras.forEach((camera, index) => {
      inputs.push(
        '-f',
        'v4l2',
        '-input_format',
        'mjpeg',
        '-video_size',
        '640x480',
        '-framerate',
        '15',
        '-i',
        camera.devicePath
      );
      filterInputs.push(`[${index}:v]`);
    });

    let filterComplex = '';

    cameras.forEach((_, index) => {
      filterComplex += `[${index}:v]scale=640:480,setsar=1[scaled${index}];`;
    });

    if (cameras.length >= 2) {
      filterComplex += `[scaled0][scaled1]hstack=inputs=2[top];`;
    } else {
      filterComplex += `[scaled0]pad=1280:480:0:0:black[top];`;
    }

    if (cameras.length >= 4) {
      filterComplex += `[scaled2][scaled3]hstack=inputs=2[bottom];`;
    } else if (cameras.length === 3) {
      filterComplex += `[scaled2]pad=1280:480:0:0:black[bottom];`;
    } else {
      filterComplex += `color=black:1280x480:d=1[bottom];`;
    }

    filterComplex += `[top][bottom]vstack=inputs=2[out]`;

    const outputArgs = ['-map', '[out]', '-f', 'mpjpeg', '-q:v', '5', '-'];

    return {
      inputs,
      filterComplex,
      outputArgs,
    };
  }
}
