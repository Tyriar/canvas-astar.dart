/**
 * canvas-astar.dart
 * MIT licensed
 *
 * Created by Daniel Imms, http://www.growingwiththeweb.com
 */
part of PathfindingVisualizer;

class AStarNode extends MapNode {
  AStarNode parent;
  double g;
  double f;

  AStarNode(int x, int y, {AStarNode this.parent: null, double cost: 0.0}) : super(x, y) {
    g = (parent != null ? parent.g : 0) + cost;
  }
}