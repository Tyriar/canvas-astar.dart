/**
 * canvas-astar.dart
 * MIT licensed
 *
 * Created by Daniel Imms, http://www.growingwiththeweb.com
 */
part of PathfindingVisualizer;

abstract class PathfindingAlgorithm {
  static final String NAME = "";
  
  List<MapNode> pathNodes;
  List<MapNode> visitedNodes;
  
  void run(MapNode start, MapNode goal, Map map);
}