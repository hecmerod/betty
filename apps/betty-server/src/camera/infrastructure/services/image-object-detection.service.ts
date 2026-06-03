import { Injectable, OnModuleInit } from '@nestjs/common';
import * as ort from 'onnxruntime-node';
import sharp from 'sharp';
import { Detection, BoundingBox } from '../../domain/entities/detection.entity';
import { YoloClassId } from '../../domain/enums/yolo-class-id.enum';

interface ModelConfig {
  modelPath: string;
  confidenceThreshold: number;
  iouThreshold: number;
  inputWidth: number;
  inputHeight: number;
}

@Injectable()
export class ImageObjectDetectionService implements OnModuleInit {
  private session: ort.InferenceSession | null = null;
  private readonly config: ModelConfig;

  constructor() {
    this.config = {
      modelPath: 'models/yolov8n.onnx',
      confidenceThreshold: parseFloat('0.5'),
      iouThreshold: parseFloat('0.45'),
      inputWidth: parseInt('640'),
      inputHeight: parseInt('640'),
    };
  }

  async onModuleInit() {
    this.session = await ort.InferenceSession.create(this.config.modelPath, {
      executionProviders: ['cpu'],
    });
  }

  async detectObjects(
    imageBuffer: Buffer,
    classId = YoloClassId.Person
  ): Promise<Detection[]> {
    const { tensor, originalWidth, originalHeight } =
      await this.preprocessImage(imageBuffer);

    const feeds = { images: tensor };
    const results = await this.session!.run(feeds);

    const detections = this.postprocessResults(
      results,
      originalWidth,
      originalHeight,
      classId
    );

    return detections;
  }

  private async preprocessImage(imageBuffer: Buffer): Promise<{
    tensor: ort.Tensor;
    originalWidth: number;
    originalHeight: number;
  }> {
    const metadata = await sharp(imageBuffer).metadata();
    const originalWidth = metadata.width || this.config.inputWidth;
    const originalHeight = metadata.height || this.config.inputHeight;

    const { data } = await sharp(imageBuffer)
      .resize(this.config.inputWidth, this.config.inputHeight, {
        fit: 'fill',
      })
      .raw()
      .toBuffer({ resolveWithObject: true });

    const channels = 3;
    const imageDataFloat = new Float32Array(
      channels * this.config.inputWidth * this.config.inputHeight
    );

    for (let c = 0; c < channels; c++) {
      for (let h = 0; h < this.config.inputHeight; h++) {
        for (let w = 0; w < this.config.inputWidth; w++) {
          const pixelIndex = (h * this.config.inputWidth + w) * channels + c;
          const tensorIndex =
            c * this.config.inputWidth * this.config.inputHeight +
            h * this.config.inputWidth +
            w;
          imageDataFloat[tensorIndex] = data[pixelIndex] / 255.0;
        }
      }
    }

    const tensor = new ort.Tensor('float32', imageDataFloat, [
      1,
      3,
      this.config.inputHeight,
      this.config.inputWidth,
    ]);

    return { tensor, originalWidth, originalHeight };
  }

  private postprocessResults(
    results: ort.InferenceSession.OnnxValueMapType,
    originalWidth: number,
    originalHeight: number,
    classId = YoloClassId.Person
  ): Detection[] {
    const output = results[Object.keys(results)[0]];
    const outputData = output.data as Float32Array;
    const dims = output.dims;

    const numClasses = 80;
    const numBoxes = dims[2];

    const detections: Array<{
      box: number[];
      confidence: number;
      classId: number;
    }> = [];

    for (let i = 0; i < numBoxes; i++) {
      const cx = outputData[i];
      const cy = outputData[numBoxes + i];
      const w = outputData[2 * numBoxes + i];
      const h = outputData[3 * numBoxes + i];

      let maxScore = 0;
      let maxClassId = 0;

      for (let c = 0; c < numClasses; c++) {
        const score = outputData[(4 + c) * numBoxes + i];
        if (score > maxScore) {
          maxScore = score;
          maxClassId = c;
        }
      }

      if (maxScore < this.config.confidenceThreshold) continue;

      if (maxClassId === classId)
        detections.push({
          box: [cx, cy, w, h],
          confidence: maxScore,
          classId: maxClassId,
        });
    }

    const scaleX = originalWidth / this.config.inputWidth;
    const scaleY = originalHeight / this.config.inputHeight;

    return detections.map((det) => {
      const x = Math.round((det.box[0] - det.box[2] / 2) * scaleX);
      const y = Math.round((det.box[1] - det.box[3] / 2) * scaleY);
      const width = Math.round(det.box[2] * scaleX);
      const height = Math.round(det.box[3] * scaleY);

      const boundingBox = new BoundingBox(x, y, width, height);

      return new Detection(classId, det.confidence, boundingBox);
    });
  }
}
