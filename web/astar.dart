/**
 * canvas-astar.dart
 * MIT licensed
 *
 * Created by Daniel Imms, http://www.growingwiththeweb.com
 */
part of PathfindingVisualizer;

class AStar implements PathfindingAlgorithm {
  final double COST_STRAIGHT = 1.0;
  final double COST_DIAGONAL = 1.414; // approximation of sqrt(2)
  
  Map map;
  
  AStar(this.map);
  
  void run(MapNode start, MapNode goal) {
    var closed = [];
    var open = [start];
    var cameFrom = [];

    open.first.f = open.first.g + heuristic(open.first, goal);

    while (open.length > 0) {
      var lowestF = 0;
      for (var i = 1; i < open.length; i++) {
        if (open[i].f < open[lowestF].f) {
          lowestF = i;
        }
      }
      var current = open[lowestF];

      if (current == goal) {
        map.draw(closed, open, current, start, goal);
        var info = 'Map size = ${map.width}x${map.height}' +
            'Total number of nodes = ${map.width * map.height}' +
            'Number of nodes in open list = ${open.length}' +
            'Number of nodes in closed list = ${closed.length}';
        querySelector('#info').text = info;
        return;
      }

      open.removeAt(lowestF);
      closed.add(current);
      map.drawVisited(current.x, current.y);

      var neighbors = neighborNodes(current);
      for (var i = 0; i < neighbors.length; i++) {
        if (indexOfNode(closed, neighbors[i]) == -1) { // Skip if in closed list
          var index = indexOfNode(open, neighbors[i]);
          if (index == -1) {
            neighbors[i].f = neighbors[i].g + heuristic(neighbors[i], goal);
            open.add(neighbors[i]);
          } else if (neighbors[i].g < open[index].g) {
            neighbors[i].f = neighbors[i].g + heuristic(neighbors[i], goal);
            open[index] = neighbors[i];
          }
        }
      }
    }

    querySelector('#info').text = 'No path exists';
  }
  
  List<AStarNode> neighborNodes(AStarNode n) {
    List<AStarNode> neighbors = new List<AStarNode>();
    var count = 0;

    if (n.x > 0) {
      if (map.isOnMap(n.x - 1, n.y) && map.obstacleMap[n.x - 1][n.y])
        neighbors.add(new AStarNode(n.x - 1, n.y, parent: n, cost: COST_STRAIGHT));
      if (n.y > 0 && map.isOnMap(n.x - 1, n.y - 1) && map.obstacleMap[n.x - 1][n.y - 1]) {
        if (map.isOnMap(n.x - 1, n.y) && map.isOnMap(n.x, n.y - 1) && map.obstacleMap[n.x - 1][n.y] && map.obstacleMap[n.x][n.y - 1])
          neighbors.add(new AStarNode(n.x - 1, n.y - 1, parent: n, cost: COST_DIAGONAL));
      }
      if (n.y < map.height && map.isOnMap(n.x - 1, n.y + 1) && map.obstacleMap[n.x - 1][n.y + 1]) {
        if (map.isOnMap(n.x - 1, n.y) && map.isOnMap(n.x, n.y + 1) && map.obstacleMap[n.x - 1][n.y] && map.obstacleMap[n.x][n.y + 1])
          neighbors.add(new AStarNode(n.x - 1, n.y + 1, parent: n, cost: COST_DIAGONAL));
      }
    }
    if (n.x < map.width - 1) {
      if (map.isOnMap(n.x + 1, n.y) && map.obstacleMap[n.x + 1][n.y])
        neighbors.add(new AStarNode(n.x + 1, n.y, parent: n, cost: COST_STRAIGHT));
      if (n.y > 0 && map.isOnMap(n.x + 1, n.y - 1) && map.obstacleMap[n.x + 1][n.y - 1]) {
        if (map.isOnMap(n.x + 1, n.y) && map.isOnMap(n.x, n.y - 1) && map.obstacleMap[n.x + 1][n.y] && map.obstacleMap[n.x][n.y - 1])
          neighbors.add(new AStarNode(n.x + 1, n.y - 1, parent: n, cost: COST_DIAGONAL));
      }
      if (n.y < map.height && map.isOnMap(n.x + 1, n.y + 1) && map.obstacleMap[n.x + 1][n.y + 1]) {
        if (map.isOnMap(n.x + 1, n.y) && map.isOnMap(n.x, n.y + 1) && map.obstacleMap[n.x + 1][n.y] && map.obstacleMap[n.x][n.y + 1])
          neighbors.add(new AStarNode(n.x + 1, n.y + 1, parent: n, cost: COST_DIAGONAL));
      }
    }
    if (n.y > 0 && map.isOnMap(n.x, n.y - 1) && map.obstacleMap[n.x][n.y - 1])
      neighbors.add(new AStarNode(n.x, n.y - 1, parent: n, cost: COST_STRAIGHT));
    if (n.y < map.height - 1 && map.isOnMap(n.x, n.y + 1) && map.obstacleMap[n.x][n.y + 1])
      neighbors.add(new AStarNode(n.x, n.y + 1, parent: n, cost: COST_STRAIGHT));

    return neighbors;
  }

  int indexOfNode(List<AStarNode> array, AStarNode node) {
    for (var i = 0; i < array.length; i++) {
      if (node == array[i])
        return i;
    }
    return -1;
  }
  
  num heuristic(node, goal) {
    return diagonalDistance(node, goal);
  }

  num manhattanDistance(node, goal) {
    return (node.x - goal.x).abs() + (node.y - goal.y).abs();
  }

  num diagonalUniformDistance(node, goal) {
    return math.max((node.x - goal.x).abs(), (node.y - goal.y).abs());
  }

  num diagonalDistance(node, goal) {
    var dmin = math.min((node.x - goal.x).abs(), (node.y - goal.y).abs());
    var dmax = math.max((node.x - goal.x).abs(), (node.y - goal.y).abs());
    return COST_DIAGONAL * dmin + COST_STRAIGHT * (dmax - dmin);
  }

  num euclideanDistance(node, goal) {
    return math.sqrt((node.x - goal.x).abs() ^ 2 + (node.y - goal.y).abs() ^ 2);
  }
}