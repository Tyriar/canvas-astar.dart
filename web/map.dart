/**
 * canvas-astar.dart
 * MIT licensed
 *
 * Created by Daniel Imms, http://www.growingwiththeweb.com
 */
part of PathfindingVisualizer;

class Map {
  final String BACKGROUND_COLOR = '#EEEEEE';
  final String OBSTACLE_COLOR   = '#2D2D30';
  final String PATH_COLOR       = '#00CC00';
  final String VISITED_COLOR    = '#4444FF';

  final int PATH_WIDTH          = 4;
  final int OBSTACLE_BRUSH_SIZE = 2; // actual size = 1 + this*2
  
  CanvasRenderingContext2D context;
  Array2d<bool> obstacleMap;
  int width;
  int height;
  int scale;
  
  Map(CanvasRenderingContext2D this.context, int this.width, int this.height, int this.scale) {
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
    int mouseX = ((e.client.x - context.canvas.offsetLeft) / scale).floor();
    int mouseY = ((e.client.y - context.canvas.offsetTop) / scale).floor();
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

  void drawOld(closed, open, AStarNode foundGoalNode, MapNode start, MapNode goal) {
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
  
  void draw(List<MapNode> path, List<MapNode> visited, MapNode start, MapNode goal) {
    drawStartGoal(goal.x, goal.y);
    drawStartGoal(start.x, start.y);

    context.beginPath();
    context.moveTo((path[0].x + 0.5) * scale, (path[0].y + 0.5) * scale);

    for (var i = 1; i < path.length; i++) {
      context.lineTo((path[i].x + 0.5) * scale, (path[i].y + 0.5) * scale);
    }

    context.strokeStyle = PATH_COLOR;
    context.lineWidth = PATH_WIDTH;
    context.stroke();
    context.closePath();
  }
}