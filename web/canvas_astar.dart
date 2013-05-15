/* 
 * canvas-astar.dart
 * MIT licensed
 *
 * Created by Daniel Imms, http://www.growingwiththeweb.com
 */
import 'dart:core';
import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'astarmap.dart';
import 'astarnode.dart';

@observable String mapWidth = '64';
@observable String mapHeight = '48';
@observable String mapScale = '10';

CanvasElement canvas;
CanvasRenderingContext2D context;
AstarMap map;
AstarNode start;
AstarNode goal;

bool isMouseDown = false;

void main() {
  canvas = query('#astar');
  resizeCanvas();
  
  context = canvas.getContext('2d') as CanvasRenderingContext2D;
  map = new AstarMap(context,  int.parse(mapWidth), int.parse(mapHeight), int.parse(mapScale));
  start = new AstarNode(0, 0);
  goal = new AstarNode(map.width - 1, map.height - 1);
  
  registerEvents(canvas);
}

void registerEvents(CanvasElement canvas) {
  canvas.onMouseDown.listen(canvasMouseDown);
  canvas.onMouseUp.listen(canvasMouseUp);
  canvas.onMouseMove.listen(canvasMouseMove);
  canvas.onContextMenu.listen((MouseEvent e) => e.preventDefault());
  query('#run').onClick.listen((e) => run());
  query('#clear').onClick.listen(clearMap);
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
  goal = new AstarNode(map.width - 1, map.height - 1);
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
  map.astar(start, goal);
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