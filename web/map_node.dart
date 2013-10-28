/**
 * canvas-astar.dart
 * MIT licensed
 *
 * Created by Daniel Imms, http://www.growingwiththeweb.com
 */
part of PathfindingVisualizer;

class MapNode {
  int x;
  int y;

  MapNode(int this.x, int this.y);

  operator ==(MapNode other) => x == other.x && y == other.y;
}