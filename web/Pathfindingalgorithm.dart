/**
 * canvas-astar.dart
 * MIT licensed
 *
 * Created by Daniel Imms, http://www.growingwiththeweb.com
 */
part of PathfindingVisualizer;

abstract class PathfindingAlgorithm {
  void run(MapNode start, MapNode goal);
}