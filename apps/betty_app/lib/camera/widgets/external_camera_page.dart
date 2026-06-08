import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/camera_service.dart';
import '../widgets/video_stream_widget.dart';
import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';
import '../bloc/camera_state.dart';

class ExternalCameraPage extends StatelessWidget {
  const ExternalCameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        // Si no hay cámara seleccionada, usar grid. Si hay una seleccionada, usar individual
        final useGrid = state.selectedCameraIndex == null;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: Hero(
                  tag: 'camera-external-hero',
                  child: Material(
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(16)),
                          child: VideoStreamWidget(
                            key: ValueKey('external-camera-$useGrid-${state.selectedCameraIndex}'),
                            cameraType: CameraType.external,
                            enableFullscreen: true,
                            heroTag: 'camera-external-hero',
                            grid: useGrid,
                            cameraIndex: state.selectedCameraIndex,
                          ),
                        ),
                        Positioned(left: 12, top: 12, child: _buildCameraControls(state, context)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraControls(CameraState state, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(left: index > 0 ? 8.0 : 0),
          child: _buildCameraButton(index, '$index', state, context),
        );
      }),
    );
  }

  Widget _buildCameraButton(int index, String label, CameraState state, BuildContext context) {
    final isSelected = state.selectedCameraIndex == index;
    return GestureDetector(
      onTap: () {
        context.read<CameraBloc>().add(SelectCameraIndexEvent(index));
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.blue.shade300 : Colors.white24, width: isSelected ? 2 : 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
