/**
 * canvas-astar.dart
 * MIT licensed
 *
 * Created by Daniel Imms, http://www.growingwiththeweb.com
 */
library PathfindingVisualizer;

import 'dart:core';
import 'dart:html';
import 'dart:math' as math;
import 'package:web_ui/web_ui.dart';

part 'array_2d.dart';
part 'astar.dart';
part 'astar_node.dart';
part 'map.dart';
part 'map_node.dart';
part 'pathfinding_algorithm.dart';

@observable String algorithm = "";
@observable String mapWidth  = '64';
@observable String mapHeight = '48';
@observable String mapScale  = '10';

CanvasElement canvas;
CanvasRenderingContext2D context;
Map map;
MapNode start;
MapNode goal;

List<PathfindingAlgorithm> algorithms = [new AStar()]; 

bool isMouseDown = false;

void main() {
  canvas = querySelector('#astar');
  resizeCanvas();
  
  context = canvas.getContext('2d') as CanvasRenderingContext2D;
  map = new Map(context,  int.parse(mapWidth), int.parse(mapHeight), int.parse(mapScale));
  start = new AStarNode(0, 0);
  goal = new AStarNode(map.width - 1, map.height - 1);
  
  var algorithmSelect = querySelector('#algorithm');
  algorithmSelect.append(new OptionElement(data: AStar.NAME, value: AStar.NAME));
  
  registerEvents(canvas);
}

void registerEvents(CanvasElement canvas) {
  canvas.onMouseDown.listen(canvasMouseDown);
  canvas.onMouseUp.listen(canvasMouseUp);
  canvas.onMouseMove.listen(canvasMouseMove);
  canvas.onContextMenu.listen((MouseEvent e) => e.preventDefault());
  querySelector('#run').onClick.listen((e) => run());
  querySelector('#clear').onClick.listen(clearMap);
}

int get canvasWidth  => int.parse(mapScale) * int.parse(mapWidth);
int get canvasHeight => int.parse(mapScale) * int.parse(mapHeight);

void resizeCanvas() {
  canvas
    ..width = canvasWidth
    ..height = canvasHeight;
}

void resizeMap() {
  map.resize(int.parse(mapWidth), int.parse(mapHeight), int.parse(mapScale));
  goal = new MapNode(map.width - 1, map.height - 1);
}

void clearMap(MouseEvent e) {
  resizeCanvas();
  resizeMap();
  map.clear();
}

void run() {
  resizeCanvas();
  resizeMap();
  map.clearPath();
  PathfindingAlgorithm pathfindingAlgorithm = new AStar();
  pathfindingAlgorithm.run(start, goal, map);
  var path = pathfindingAlgorithm.pathNodes;
  var visited = pathfindingAlgorithm.visitedNodes;
  map.draw(path, visited, start, goal);
}

void canvasMouseDown(MouseEvent e) {
  isMouseDown = true;
  map.placeObstacles(e);
}

void canvasMouseUp(MouseEvent e) {
  isMouseDown = false;
}

void canvasMouseMove(MouseEvent e) {
  if (isMouseDown)
    map.placeObstacles(e);
}