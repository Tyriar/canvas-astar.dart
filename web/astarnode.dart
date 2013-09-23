/* 
 * canvas-astar.dart
 * MIT licensed
 *
 * Created by Daniel Imms, http://www.growingwiththeweb.com
 */
library Astarnode;

class AstarNode {
  AstarNode parent;
  int x;
  int y;
  double g;
  double f;

  AstarNode(int this.x, int this.y, {AstarNode this.parent: null, double cost: 0.0}) {
    g = (parent != null ? parent.g : 0) + cost;
  }

  operator ==(AstarNode other) => x == other.x && y == other.y;
}