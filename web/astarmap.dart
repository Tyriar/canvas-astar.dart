/* 
 * canvas-astar.dart
 * MIT licensed
 *
 * Created by Daniel Imms, http://www.growingwiththeweb.com
 */
import 'dart:html';
import 'dart:math' as math;
import 'astarnode.dart';
import 'array2d.dart';

class AstarMap {  
  final String BACKGROUND_COLOR = '#EEE';
  final String OBSTACLE_COLOR = '#2D2D30';
  final String PATH_COLOR = '#0C0';
  final String VISITED_COLOR = '#44F';

  final int PATH_WIDTH = 4;
  final int OBSTACLE_BRUSH_SIZE = 2; // actual size = 1 + this*2
  final double COST_STRAIGHT = 1.0;
  final double COST_DIAGONAL = 1.414; // approximation of sqrt(2)
  
  CanvasRenderingContext2D context;
  Array2d<bool> obstacleMap;
  int width;
  int height;
  int scale;
  
  AstarMap(CanvasRenderingContext2D this.context, int this.width, int this.height, int this.scale) {
    initObstacleMap();
    clear();
  }

  bool isOnMap(int x, int y) => x >= 0 && x < width && y >= 0 && y < height;
  
  void initObstacleMap() {
    obstacleMap = new Array2d<bool>(width, height, defaultValue: true);
  }
  
  void resize(int width, int height, int scale) {
    bool resetMap = (this.width != width || this.height != height);
    this.width = width;
    this.height = height;
    this.scale = scale;
    if (resetMap)
      initObstacleMap();
  }

  void clear() {
    context.fillStyle = BACKGROUND_COLOR;
    context.fillRect(0, 0, context.canvas.width, context.canvas.height);

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        obstacleMap[x][y] = true;
      }
    }
  }
  
  void clearPath() {
    context.fillStyle = BACKGROUND_COLOR;
    context.fillRect(0, 0, context.canvas.width, context.canvas.height);
    drawObstacles();
  }

  void drawObstacles() {
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        if (!obstacleMap[x][y]) {
          drawObstacle(x, y);
        }
      }
    }
  }
  
  void placeObstacles(MouseEvent e) {
    int mouseX = ((e.clientX - context.canvas.offsetLeft) / scale).floor();
    int mouseY = ((e.clientY - context.canvas.offsetTop) / scale).floor();
    for (var x = mouseX - OBSTACLE_BRUSH_SIZE; x <= mouseX + OBSTACLE_BRUSH_SIZE; x++) {
      for (var y = mouseY - OBSTACLE_BRUSH_SIZE; y <= mouseY + OBSTACLE_BRUSH_SIZE; y++) {
        if (e.button == 0) { // left-click
          if (isOnMap(x, y) && obstacleMap[x][y]) {
            obstacleMap[x][y] = false;
            drawObstacle(x, y);
          }
        } else if (e.button == 2) { // right-click
          if (isOnMap(x, y) && !obstacleMap[x][y]) {
            obstacleMap[x][y] = true;
            clearObstacle(x, y);
          }
        }
      }
    }
  }
  
  void drawObstacle(int x, int y)  => drawNode(x, y, OBSTACLE_COLOR);
  void clearObstacle(int x, int y) => drawNode(x, y, BACKGROUND_COLOR);
  void drawVisited(int x, int y)   => drawNode(x, y, VISITED_COLOR);
  void drawStartGoal(int x, int y) => drawNode(x, y, PATH_COLOR);

  void drawNode(int x, int y, String color) {
    context.fillStyle = color;
    context.fillRect(x * scale, y * scale, scale, scale);
  }

  void astar(AstarNode start, AstarNode goal) {
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
        draw(closed, open, current, start, goal);
        var info = 'Map size = ${width}x${height}' +
            'Total number of nodes = ${width * height}' +
            'Number of nodes in open list = ${open.length}' +
            'Number of nodes in closed list = ${closed.length}';
        query('#info').text = info;
        return;
      }

      open.removeAt(lowestF);
      closed.add(current);
      drawVisited(current.x, current.y);

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

    query('#info').text = 'No path exists';
  }
  
  List<AstarNode> neighborNodes(AstarNode n) {
    List<AstarNode> neighbors = new List<AstarNode>();
    var count = 0;

    if (n.x > 0) {
      if (isOnMap(n.x - 1, n.y) && obstacleMap[n.x - 1][n.y])
        neighbors.add(new AstarNode(n.x - 1, n.y, parent: n, cost: COST_STRAIGHT));
      if (n.y > 0 && isOnMap(n.x - 1, n.y - 1) && obstacleMap[n.x - 1][n.y - 1]) {
        if (isOnMap(n.x - 1, n.y) && isOnMap(n.x, n.y - 1) && obstacleMap[n.x - 1][n.y] && obstacleMap[n.x][n.y - 1])
          neighbors.add(new AstarNode(n.x - 1, n.y - 1, parent: n, cost: COST_DIAGONAL));
      }
      if (n.y < height && isOnMap(n.x - 1, n.y + 1) && obstacleMap[n.x - 1][n.y + 1]) {
        if (isOnMap(n.x - 1, n.y) && isOnMap(n.x, n.y + 1) && obstacleMap[n.x - 1][n.y] && obstacleMap[n.x][n.y + 1])
          neighbors.add(new AstarNode(n.x - 1, n.y + 1, parent: n, cost: COST_DIAGONAL));
      }
    }
    if (n.x < width - 1) {
      if (isOnMap(n.x + 1, n.y) && obstacleMap[n.x + 1][n.y])
        neighbors.add(new AstarNode(n.x + 1, n.y, parent: n, cost: COST_STRAIGHT));
      if (n.y > 0 && isOnMap(n.x + 1, n.y - 1) && obstacleMap[n.x + 1][n.y - 1]) {
        if (isOnMap(n.x + 1, n.y) && isOnMap(n.x, n.y - 1) && obstacleMap[n.x + 1][n.y] && obstacleMap[n.x][n.y - 1])
          neighbors.add(new AstarNode(n.x + 1, n.y - 1, parent: n, cost: COST_DIAGONAL));
      }
      if (n.y < height && isOnMap(n.x + 1, n.y + 1) && obstacleMap[n.x + 1][n.y + 1]) {
        if (isOnMap(n.x + 1, n.y) && isOnMap(n.x, n.y + 1) && obstacleMap[n.x + 1][n.y] && obstacleMap[n.x][n.y + 1])
          neighbors.add(new AstarNode(n.x + 1, n.y + 1, parent: n, cost: COST_DIAGONAL));
      }
    }
    if (n.y > 0 && isOnMap(n.x, n.y - 1) && obstacleMap[n.x][n.y - 1])
      neighbors.add(new AstarNode(n.x, n.y - 1, parent: n, cost: COST_STRAIGHT));
    if (n.y < height - 1 && isOnMap(n.x, n.y + 1) && obstacleMap[n.x][n.y + 1])
      neighbors.add(new AstarNode(n.x, n.y + 1, parent: n, cost: COST_STRAIGHT));

    return neighbors;
  }

  int indexOfNode(List<AstarNode> array, AstarNode node) {
    for (var i = 0; i < array.length; i++) {
      if (node == array[i])
        return i;
    }
    return -1;
  }

  void draw(closed, open, AstarNode foundGoalNode, AstarNode start, AstarNode goal) {
    drawStartGoal(goal.x, goal.y);
    drawStartGoal(start.x, start.y);

    context.beginPath();
    context.moveTo((foundGoalNode.x + 0.5) * scale, (foundGoalNode.y + 0.5) * scale);

    while (foundGoalNode.parent != null) {
      foundGoalNode = foundGoalNode.parent;
      context.lineTo((foundGoalNode.x + 0.5) * scale, (foundGoalNode.y + 0.5) * scale);
    }

    context.strokeStyle = PATH_COLOR;
    context.lineWidth = PATH_WIDTH;
    context.stroke();
    context.closePath();
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