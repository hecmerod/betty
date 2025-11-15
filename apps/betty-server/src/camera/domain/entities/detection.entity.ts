export class BoundingBox {
  constructor(
    public readonly x: number,
    public readonly y: number,
    public readonly width: number,
    public readonly height: number
  ) {}

  toJSON() {
    return {
      x: this.x,
      y: this.y,
      width: this.width,
      height: this.height,
    };
  }
}

export class Detection {
  constructor(
    public readonly className: string,
    public readonly confidence: number,
    public readonly boundingBox: BoundingBox,
    public readonly timestamp: Date = new Date()
  ) {}

  toJSON() {
    return {
      class_name: this.className,
      confidence: this.confidence,
      bounding_box: this.boundingBox.toJSON(),
      timestamp: this.timestamp.toISOString(),
    };
  }
}

export class DetectionResult {
  constructor(
    public readonly detections: Detection[],
    public readonly frameWidth: number,
    public readonly frameHeight: number,
    public readonly processingTimeMs: number
  ) {}

  get totalDetections(): number {
    return this.detections.length;
  }

  toJSON() {
    return {
      detections: this.detections.map((d) => d.toJSON()),
      frame_width: this.frameWidth,
      frame_height: this.frameHeight,
      processing_time_ms: this.processingTimeMs,
      total_detections: this.totalDetections,
    };
  }
}
