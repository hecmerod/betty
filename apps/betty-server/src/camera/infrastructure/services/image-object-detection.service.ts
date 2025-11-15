import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as ort from 'onnxruntime-node';
import sharp from 'sharp';
import { Detection, BoundingBox } from '../../domain/entities/detection.entity';

interface ModelConfig {
  modelPath: string;
  confidenceThreshold: number;
  iouThreshold: number;
  inputWidth: number;
  inputHeight: number;
}

@Injectable()
export class ImageObjectDetectionService implements OnModuleInit {
  private readonly logger = new Logger(ImageObjectDetectionService.name);
  private session: ort.InferenceSession | null = null;
  private readonly config: ModelConfig;

  constructor() {
    this.config = {
      modelPath:
        process.env.YOLO_MODEL_PATH || 'models/yolov8n_ncnn_model/yolov8n.onnx',
      confidenceThreshold: parseFloat(
        process.env.YOLO_CONFIDENCE_THRESHOLD || '0.5'
      ),
      iouThreshold: parseFloat(process.env.YOLO_IOU_THRESHOLD || '0.45'),
      inputWidth: parseInt(process.env.YOLO_INPUT_WIDTH || '640'),
      inputHeight: parseInt(process.env.YOLO_INPUT_HEIGHT || '640'),
    };
  }

  async onModuleInit() {
    this.session = await ort.InferenceSession.create(this.config.modelPath, {
      executionProviders: ['cpu'],
    });
  }

  async detectObjects(imageBuffer: Buffer): Promise<Detection[]> {
    const { tensor, originalWidth, originalHeight } =
      await this.preprocessImage(imageBuffer);

    const feeds = { images: tensor };
    const results = await this.session.run(feeds);

    const detections = this.postprocessResults(
      results,
      originalWidth,
      originalHeight
    );

    return detections;
  }

  private async preprocessImage(imageBuffer: Buffer): Promise<{
    tensor: ort.Tensor;
    originalWidth: number;
    originalHeight: number;
  }> {
    // Obtener dimensiones originales
    const metadata = await sharp(imageBuffer).metadata();
    const originalWidth = metadata.width || this.config.inputWidth;
    const originalHeight = metadata.height || this.config.inputHeight;

    // Redimensionar y convertir a RGB
    const { data } = await sharp(imageBuffer)
      .resize(this.config.inputWidth, this.config.inputHeight, {
        fit: 'fill',
      })
      .raw()
      .toBuffer({ resolveWithObject: true });

    // Convertir a formato CHW (Channels, Height, Width) y normalizar
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
          // Normalizar a [0, 1]
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
    originalHeight: number
  ): Detection[] {
    // Obtener output del modelo (formato YOLOv8: [1, 84, 8400] o similar)
    const output = results[Object.keys(results)[0]];
    const outputData = output.data as Float32Array;
    const dims = output.dims;

    // YOLOv8 output: [batch, 84, num_boxes]
    // 84 = 4 (bbox) + 80 (classes)
    const numClasses = 80;
    const numBoxes = dims[2];

    const detections: Array<{
      box: number[];
      confidence: number;
      classId: number;
    }> = [];

    // Transponer y procesar cada detection
    for (let i = 0; i < numBoxes; i++) {
      // Extraer coordenadas del bounding box (cx, cy, w, h)
      const cx = outputData[i];
      const cy = outputData[numBoxes + i];
      const w = outputData[2 * numBoxes + i];
      const h = outputData[3 * numBoxes + i];

      // Encontrar clase con mayor confianza
      let maxScore = 0;
      let maxClassId = 0;

      for (let c = 0; c < numClasses; c++) {
        const score = outputData[(4 + c) * numBoxes + i];
        if (score > maxScore) {
          maxScore = score;
          maxClassId = c;
        }
      }

      // Filtrar por threshold de confianza
      if (maxScore >= this.config.confidenceThreshold) {
        // Solo detectar personas (class 0 en COCO)
        if (maxClassId === 0) {
          detections.push({
            box: [cx, cy, w, h],
            confidence: maxScore,
            classId: maxClassId,
          });
        }
      }
    }

    // Aplicar Non-Maximum Suppression (NMS)
    const nmsDetections = this.applyNMS(detections);

    // Convertir a formato de dominio
    const scaleX = originalWidth / this.config.inputWidth;
    const scaleY = originalHeight / this.config.inputHeight;

    return nmsDetections.map((det) => {
      // Convertir de (cx, cy, w, h) a (x, y, w, h) en coordenadas originales
      const x = Math.round((det.box[0] - det.box[2] / 2) * scaleX);
      const y = Math.round((det.box[1] - det.box[3] / 2) * scaleY);
      const width = Math.round(det.box[2] * scaleX);
      const height = Math.round(det.box[3] * scaleY);

      const boundingBox = new BoundingBox(x, y, width, height);

      return new Detection('person', det.confidence, boundingBox);
    });
  }

  private applyNMS(
    detections: Array<{ box: number[]; confidence: number; classId: number }>
  ): Array<{ box: number[]; confidence: number; classId: number }> {
    // Ordenar por confianza descendente
    detections.sort((a, b) => b.confidence - a.confidence);

    const selected: typeof detections = [];

    while (detections.length > 0) {
      const current = detections.shift();
      if (!current) break;
      selected.push(current);

      // Filtrar detecciones que se superponen demasiado
      detections = detections.filter((det) => {
        const iou = this.calculateIoU(current.box, det.box);
        return iou < this.config.iouThreshold;
      });
    }

    return selected;
  }

  private calculateIoU(box1: number[], box2: number[]): number {
    // Convertir de (cx, cy, w, h) a (x1, y1, x2, y2)
    const box1x1 = box1[0] - box1[2] / 2;
    const box1y1 = box1[1] - box1[3] / 2;
    const box1x2 = box1[0] + box1[2] / 2;
    const box1y2 = box1[1] + box1[3] / 2;

    const box2x1 = box2[0] - box2[2] / 2;
    const box2y1 = box2[1] - box2[3] / 2;
    const box2x2 = box2[0] + box2[2] / 2;
    const box2y2 = box2[1] + box2[3] / 2;

    // Calcular área de intersección
    const intersectX1 = Math.max(box1x1, box2x1);
    const intersectY1 = Math.max(box1y1, box2y1);
    const intersectX2 = Math.min(box1x2, box2x2);
    const intersectY2 = Math.min(box1y2, box2y2);

    const intersectArea =
      Math.max(0, intersectX2 - intersectX1) *
      Math.max(0, intersectY2 - intersectY1);

    // Calcular área de unión
    const box1Area = box1[2] * box1[3];
    const box2Area = box2[2] * box2[3];
    const unionArea = box1Area + box2Area - intersectArea;

    return intersectArea / unionArea;
  }
}
