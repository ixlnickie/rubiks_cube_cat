import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' show Vector3, Matrix4;

void main() => runApp(const Rubiks3DApp());

class Rubiks3DApp extends StatelessWidget {
  const Rubiks3DApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Rubiks3DScreen(),
      );
}

class Rubiks3DScreen extends StatefulWidget {
  const Rubiks3DScreen({super.key});
  @override
  State<Rubiks3DScreen> createState() => _Rubiks3DScreenState();
}

class _Rubiks3DScreenState extends State<Rubiks3DScreen> {
  late List<List<Color>> cube;
  double rotX = -0.5;
  double rotY = 0.5;
  
  Offset? _tapPosition;
  int? _selectedLayer;
  bool _isAnimating = false;
  
  final List<List<List<Color>>> _history = [];
  static const int _maxHistorySize = 20;

  @override
  void initState() {
    super.initState();
    _resetCube();
  }

  void _resetCube() {
    setState(() {
      cube = [
        List.generate(9, (_) => Colors.red),
        List.generate(9, (_) => Colors.orange),
        List.generate(9, (_) => Colors.white),
        List.generate(9, (_) => Colors.yellow),
        List.generate(9, (_) => Colors.green),
        List.generate(9, (_) => Colors.blue),
      ];
      _history.clear();
      _saveToHistory();
    });
  }

  void _saveToHistory() {
    List<List<Color>> snapshot = [];
    for (var face in cube) {
      snapshot.add(List.from(face));
    }
    _history.add(snapshot);
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }
  }

  void _undo() {
    if (_history.length > 1) {
      setState(() {
        _history.removeLast();
        cube = [];
        for (var face in _history.last) {
          cube.add(List.from(face));
        }
      });
    }
  }

  void rotateU() {
    _saveToHistory();
    setState(() {
      var tmp = [cube[0][0], cube[0][1], cube[0][2]];
      cube[0][0] = cube[5][0]; cube[0][1] = cube[5][1]; cube[0][2] = cube[5][2];
      cube[5][0] = cube[1][0]; cube[5][1] = cube[1][1]; cube[5][2] = cube[1][2];
      cube[1][0] = cube[4][0]; cube[1][1] = cube[4][1]; cube[1][2] = cube[4][2];
      cube[4][0] = tmp[0]; cube[4][1] = tmp[1]; cube[4][2] = tmp[2];
      _rotateFaceClockwise(2);
    });
  }

  void rotateD() {
    _saveToHistory();
    setState(() {
      var tmp = [cube[0][6], cube[0][7], cube[0][8]];
      cube[0][6] = cube[4][6]; cube[0][7] = cube[4][7]; cube[0][8] = cube[4][8];
      cube[4][6] = cube[1][6]; cube[4][7] = cube[1][7]; cube[4][8] = cube[1][8];
      cube[1][6] = cube[5][6]; cube[1][7] = cube[5][7]; cube[1][8] = cube[5][8];
      cube[5][6] = tmp[0]; cube[5][7] = tmp[1]; cube[5][8] = tmp[2];
      _rotateFaceClockwise(3);
    });
  }

  void rotateL() {
    _saveToHistory();
    setState(() {
      var tmp = [cube[0][0], cube[0][3], cube[0][6]];
      cube[0][0] = cube[2][0]; cube[0][3] = cube[2][3]; cube[0][6] = cube[2][6];
      cube[2][0] = cube[1][8]; cube[2][3] = cube[1][5]; cube[2][6] = cube[1][2];
      cube[1][8] = cube[3][8]; cube[1][5] = cube[3][5]; cube[1][2] = cube[3][2];
      cube[3][8] = tmp[0]; cube[3][5] = tmp[1]; cube[3][2] = tmp[2];
      _rotateFaceClockwise(4);
    });
  }

  void rotateR() {
    _saveToHistory();
    setState(() {
      var tmp = [cube[0][2], cube[0][5], cube[0][8]];
      cube[0][2] = cube[3][2]; cube[0][5] = cube[3][5]; cube[0][8] = cube[3][8];
      cube[3][2] = cube[1][6]; cube[3][5] = cube[1][3]; cube[3][8] = cube[1][0];
      cube[1][6] = cube[2][6]; cube[1][3] = cube[2][3]; cube[1][0] = cube[2][0];
      cube[2][6] = tmp[0]; cube[2][3] = tmp[1]; cube[2][0] = tmp[2];
      _rotateFaceClockwise(5);
    });
  }

  void rotateF() {
    _saveToHistory();
    setState(() {
      var tmp = [cube[2][6], cube[2][7], cube[2][8]];
      cube[2][6] = cube[4][8]; cube[2][7] = cube[4][5]; cube[2][8] = cube[4][2];
      cube[4][8] = cube[3][2]; cube[4][5] = cube[3][1]; cube[4][2] = cube[3][0];
      cube[3][2] = cube[5][0]; cube[3][1] = cube[5][3]; cube[3][0] = cube[5][6];
      cube[5][0] = tmp[0]; cube[5][3] = tmp[1]; cube[5][6] = tmp[2];
      _rotateFaceClockwise(0);
    });
  }

  void rotateB() {
    _saveToHistory();
    setState(() {
      var tmp = [cube[2][0], cube[2][1], cube[2][2]];
      cube[2][0] = cube[5][2]; cube[2][1] = cube[5][5]; cube[2][2] = cube[5][8];
      cube[5][2] = cube[3][8]; cube[5][5] = cube[3][7]; cube[5][8] = cube[3][6];
      cube[3][8] = cube[4][0]; cube[3][7] = cube[4][3]; cube[3][6] = cube[4][6];
      cube[4][0] = tmp[0]; cube[4][3] = tmp[1]; cube[4][6] = tmp[2];
      _rotateFaceClockwise(1);
    });
  }

  void _rotateFaceClockwise(int face) {
    List<Color> o = List.from(cube[face]);
    cube[face][0] = o[6]; cube[face][1] = o[3]; cube[face][2] = o[0];
    cube[face][3] = o[7]; cube[face][4] = o[4]; cube[face][5] = o[1];
    cube[face][6] = o[8]; cube[face][7] = o[5]; cube[face][8] = o[2];
  }

  int? _getLayerFromTap(Offset tapPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final Matrix4 matrix = Matrix4.identity()..rotateX(rotX)..rotateY(rotY);
    List<_FaceHit> hits = [];
    for (int face = 0; face < 6; face++) {
      for (int i = 0; i < 9; i++) {
        final sticker = _getStickerPosition(face, i, matrix, center);
        if (sticker != null && _pointInPolygon(tapPosition, sticker.points)) {
          hits.add(_FaceHit(face, sticker.z, i));
          break;
        }
      }
    }
    if (hits.isNotEmpty) {
      hits.sort((a, b) => a.z.compareTo(b.z));
      final hit = hits.last;
      return _getLayerFromFaceAndIndex(hit.face, hit.index);
    }
    return null;
  }

  int? _getLayerFromFaceAndIndex(int face, int index) {
    int row = index ~/ 3;
    int col = index % 3;
    switch (face) {
      case 0:
        if (row == 0) return 0; if (row == 2) return 1; if (col == 0) return 2; if (col == 2) return 3;
        break;
      case 1:
        if (row == 0) return 0; if (row == 2) return 1; if (col == 0) return 3; if (col == 2) return 2;
        break;
      case 2:
        if (col == 0) return 2; if (col == 2) return 3; if (row == 0) return 5; if (row == 2) return 4;
        break;
      case 3:
        if (col == 0) return 2; if (col == 2) return 3; if (row == 0) return 4; if (row == 2) return 5;
        break;
      case 4:
        if (row == 0) return 0; if (row == 2) return 1; if (col == 0) return 5; if (col == 2) return 4;
        break;
      case 5:
        if (row == 0) return 0; if (row == 2) return 1; if (col == 0) return 4; if (col == 2) return 5;
        break;
    }
    return null;
  }

  bool _pointInPolygon(Offset point, List<Offset> polygon) {
    int i, j = polygon.length - 1;
    bool oddNodes = false;
    for (i = 0; i < polygon.length; i++) {
      if ((polygon[i].dy < point.dy && polygon[j].dy >= point.dy ||
          polygon[j].dy < point.dy && polygon[i].dy >= point.dy) &&
          (polygon[i].dx <= point.dx || polygon[j].dx <= point.dx)) {
        double intersection = polygon[i].dx + (point.dy - polygon[i].dy) / (polygon[j].dy - polygon[i].dy) * (polygon[j].dx - polygon[i].dx);
        if (intersection < point.dx) oddNodes = !oddNodes;
      }
      j = i;
    }
    return oddNodes;
  }

  _Sticker? _getStickerPosition(int face, int idx, Matrix4 m, Offset center) {
    double x = (idx % 3 - 1) * 44.0, y = (idx ~/ 3 - 1) * 44.0, s = 21.0, p = 66.0;
    List<Vector3> v;
    switch (face) {
      case 0: v = [Vector3(x-s,y-s,p), Vector3(x+s,y-s,p), Vector3(x+s,y+s,p), Vector3(x-s,y+s,p)]; break;
      case 1: v = [Vector3(-x+s,y-s,-p), Vector3(-x-s,y-s,-p), Vector3(-x-s,y+s,-p), Vector3(-x+s,y+s,-p)]; break;
      case 2: v = [Vector3(x-s,-p,y-s), Vector3(x+s,-p,y-s), Vector3(x+s,-p,y+s), Vector3(x-s,-p,y+s)]; break;
      case 3: v = [Vector3(x-s,p,-y+s), Vector3(x+s,p,-y+s), Vector3(x+s,p,-y-s), Vector3(x-s,p,-y-s)]; break;
      case 4: v = [Vector3(-p,x-s,y+s), Vector3(-p,x+s,y+s), Vector3(-p,x+s,y-s), Vector3(-p,x-s,y-s)]; break;
      case 5: v = [Vector3(p,x-s,y-s), Vector3(p,x+s,y-s), Vector3(p,x+s,y+s), Vector3(p,x-s,y+s)]; break;
      default: return null;
    }
    List<Offset> points = v.map((v3) {
      final t = m.transform3(v3);
      return Offset(t.x + center.dx, t.y + center.dy);
    }).toList();
    double z = v.map((v3) => m.transform3(v3).z).reduce((a, b) => a + b) / 4;
    final v1 = points[1] - points[0], v2 = points[2] - points[0];
    return _Sticker(points, cube[face][idx], z, (v1.dx * v2.dy - v1.dy * v2.dx) > 0, face, idx);
  }

  void _onTapDown(TapDownDetails details) {
    if (_isAnimating) return;
    _tapPosition = details.localPosition;
  }

  void _onTapUp(TapUpDetails details) {
    if (_isAnimating || _tapPosition == null) return;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final tappedLayer = _getLayerFromTap(_tapPosition!, renderBox.size);
    if (tappedLayer != null) {
      setState(() { _selectedLayer = tappedLayer; _isAnimating = true; });
      Future.delayed(const Duration(milliseconds: 150), () {
        switch (tappedLayer) {
          case 0: rotateU(); break;
          case 1: rotateD(); break;
          case 2: rotateL(); break;
          case 3: rotateR(); break;
          case 4: rotateF(); break;
          case 5: rotateB(); break;
        }
        setState(() { _selectedLayer = null; _isAnimating = false; });
      });
    }
    _tapPosition = null;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isAnimating) {
      setState(() {
        rotY += details.delta.dx * 0.01;
        rotX -= details.delta.dy * 0.01;
        rotX = rotX.clamp(-1.5, 1.5);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onPanUpdate: _onPanUpdate,
            child: CustomPaint(
              painter: CubePainter(
                cube: cube, rotX: rotX, rotY: rotY, selectedLayer: _selectedLayer,
              ),
              size: Size.infinite,
            ),
          ),
          
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(icon: Icons.refresh, onTap: _resetCube, color: Colors.white),
                const SizedBox(width: 20),
                _buildControlButton(icon: Icons.undo, onTap: _undo, color: Colors.orange, enabled: _history.length > 1),
              ],
            ),
          ),
          
          // Твоя авторская подпись
          const Positioned(
            bottom: 100, left: 0, right: 0,
            child: Center(
              child: Text(
                "created by ixlnickie",
                style: TextStyle(
                  color: Colors.white10,
                  fontSize: 12,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onTap, required Color color, bool enabled = true}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: enabled ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.3), width: 2),
        ),
        child: Icon(icon, color: enabled ? color : Colors.grey, size: 24),
      ),
    );
  }
}

class CubePainter extends CustomPainter {
  final List<List<Color>> cube;
  final double rotX, rotY;
  final int? selectedLayer;
  CubePainter({required this.cube, required this.rotX, required this.rotY, this.selectedLayer});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final matrix = Matrix4.identity()..rotateX(rotX)..rotateY(rotY);
    List<_Sticker> stickers = [];
    for (int f = 0; f < 6; f++) {
      for (int i = 0; i < 9; i++) {
        final s = _buildSticker(f, i, matrix, center);
        if (s != null) stickers.add(s);
      }
    }
    stickers.sort((a, b) => a.z.compareTo(b.z));
    for (var s in stickers) {
      if (s.isVisible) {
        final path = Path()..moveTo(s.points[0].dx, s.points[0].dy);
        for (int i = 1; i < s.points.length; i++) path.lineTo(s.points[i].dx, s.points[i].dy);
        path.close();
        Paint fillPaint = Paint()..color = s.color;
        if (_isInSelectedLayer(s.face, s.index)) {
          canvas.drawPath(path, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 4.0);
          fillPaint.color = s.color.withOpacity(0.9);
        }
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
    }
  }

  bool _isInSelectedLayer(int face, int index) {
    if (selectedLayer == null) return false;
    int r = index ~/ 3, c = index % 3;
    switch (selectedLayer) {
      case 0: return (face == 0 && r == 0) || (face == 1 && r == 0) || face == 2 || (face == 4 && r == 0) || (face == 5 && r == 0);
      case 1: return (face == 0 && r == 2) || (face == 1 && r == 2) || face == 3 || (face == 4 && r == 2) || (face == 5 && r == 2);
      case 2: return (face == 0 && c == 0) || (face == 1 && c == 2) || (face == 2 && c == 0) || (face == 3 && c == 0) || face == 4;
      case 3: return (face == 0 && c == 2) || (face == 1 && c == 0) || (face == 2 && c == 2) || (face == 3 && c == 2) || face == 5;
      case 4: return face == 0 || (face == 2 && r == 2) || (face == 3 && r == 0) || (face == 4 && c == 2) || (face == 5 && c == 0);
      case 5: return face == 1 || (face == 2 && r == 0) || (face == 3 && r == 2) || (face == 4 && c == 0) || (face == 5 && c == 2);
      default: return false;
    }
  }

  _Sticker? _buildSticker(int face, int idx, Matrix4 m, Offset center) {
    double x = (idx % 3 - 1) * 44.0, y = (idx ~/ 3 - 1) * 44.0, s = 21.0, p = 66.0;
    List<Vector3> v;
    switch (face) {
      case 0: v = [Vector3(x-s,y-s,p), Vector3(x+s,y-s,p), Vector3(x+s,y+s,p), Vector3(x-s,y+s,p)]; break;
      case 1: v = [Vector3(-x+s,y-s,-p), Vector3(-x-s,y-s,-p), Vector3(-x-s,y+s,-p), Vector3(-x+s,y+s,-p)]; break;
      case 2: v = [Vector3(x-s,-p,y-s), Vector3(x+s,-p,y-s), Vector3(x+s,-p,y+s), Vector3(x-s,-p,y+s)]; break;
      case 3: v = [Vector3(x-s,p,-y+s), Vector3(x+s,p,-y+s), Vector3(x+s,p,-y-s), Vector3(x-s,p,-y-s)]; break;
      case 4: v = [Vector3(-p,x-s,y+s), Vector3(-p,x+s,y+s), Vector3(-p,x+s,y-s), Vector3(-p,x-s,y-s)]; break;
      case 5: v = [Vector3(p,x-s,y-s), Vector3(p,x+s,y-s), Vector3(p,x+s,y+s), Vector3(p,x-s,y+s)]; break;
      default: return null;
    }
    List<Offset> pts = v.map((v3) {
      final t = m.transform3(v3);
      return Offset(t.x + center.dx, t.y + center.dy);
    }).toList();
    double z = v.map((v3) => m.transform3(v3).z).reduce((a, b) => a + b) / 4;
    final v1 = pts[1] - pts[0], v2 = pts[2] - pts[0];
    return _Sticker(pts, cube[face][idx], z, (v1.dx * v2.dy - v1.dy * v2.dx) > 0, face, idx);
  }
  @override bool shouldRepaint(covariant CustomPainter old) => true;
}

class _Sticker {
  final List<Offset> points; final Color color; final double z; final bool isVisible; final int face; final int index;
  _Sticker(this.points, this.color, this.z, this.isVisible, this.face, this.index);
}

class _FaceHit { final int face; final double z; final int index; _FaceHit(this.face, this.z, this.index); }