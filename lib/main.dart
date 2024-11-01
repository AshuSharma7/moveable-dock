import 'dart:developer';

import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<IconData> items;

  /// Builder building the provided [T] item.
  final Widget Function(IconData) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> with SingleTickerProviderStateMixin {
  /// [T] items being manipulated.
  late final List<IconData> _items = widget.items.toList();

  IconData? _draggedItem;
  int _hoveredIndex = -1;
  bool _isAnimating = false;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          _items.length + (_draggedItem != null ? 1 : 0),
          (index) {
            return _dockIcon(index);
          },
        ),
      ),
    );
  }

  /// Show dragging icon or placeholder
  Widget _dockIcon(int index) {
    int itemIndex = index;
    if(!_isHovering && _draggedItem != null && index == _hoveredIndex) {
      return 
      SizedBox.shrink();
    }

    if (_draggedItem != null && index == _hoveredIndex) {
      return DragTarget(
       onWillAcceptWithDetails: (data) {
        log(data.offset.dy.toString());
        if (!_isAnimating) {
          setState(() {
            _hoveredIndex = index;
          });
        }
        setState(() {
          _isHovering = true;
        });
        return true;
      },
      onLeave: (data) {
        if (!_isAnimating) {
          setState(() {
            _hoveredIndex = -1;
          });
        }
        setState(() {
          _isHovering = false;
        });
      },
      onAcceptWithDetails: (data) {
        _moveDraggedItemToIndex(itemIndex);
      },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            key: ValueKey(index),
        duration: const Duration(milliseconds: 300),
        width: _isHovering ? 48 : 8, 
        height: 48,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
            );
        },
        // child: 
      );
    } else
     if (_draggedItem != null && index > _hoveredIndex) {
      itemIndex--;
    }

    if (itemIndex < 0 || itemIndex >= _items.length) {
      return const SizedBox.shrink();
    }

    return DragTarget<IconData>(
      onWillAcceptWithDetails: (data) {
        log(data.offset.dy.toString());
        if (!_isAnimating) {
          setState(() {
            _hoveredIndex = index;
          });
        }
        setState(() {
          _isHovering = true;
        });
        return true;
      },
      onLeave: (data) {
        if (!_isAnimating) {
          setState(() {
            _hoveredIndex = -1;
          });
        }
        setState(() {
          _isHovering = false;
        });
      },
      onAcceptWithDetails: (data) {
        _moveDraggedItemToIndex(itemIndex);
      },
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<IconData>(
          data: _items[itemIndex],
          onDragStarted: () {
            setState(() {
              _draggedItem = _items[itemIndex];
              _items.removeAt(itemIndex);
            });
          },
          onDragEnd: (_) {
            if (_hoveredIndex == -1) {
              _cancelDrag();
            }
          },
          onDragUpdate: (details) {
            log(details.localPosition.dx.toString());
          },
          onDraggableCanceled: (vel, offset) {
            _cancelDrag();
          },
          
          feedback: Material(
            color: Colors.transparent,
            child: widget.builder(_items[itemIndex]),
          ),
          childWhenDragging: const SizedBox.shrink(),
          child: AnimatedContainer(
            // key: ValueKey(_items[index]),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.all(2),
            child: widget.builder(_items[itemIndex]),
          ),
        );
      },
    );
  }

  void _moveDraggedItemToIndex(int realIndex) {
    setState(() {
      _isAnimating = true;
      _items.insert(realIndex, _draggedItem!); 
      _draggedItem = null;
      _hoveredIndex = -1;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _isAnimating = false;
      });
    });
  }

  void _cancelDrag() {
    setState(() {
      if (_draggedItem != null) {
        _items.insert(_hoveredIndex == -1 ? _items.length : _hoveredIndex, _draggedItem!);
      }
      _draggedItem = null;
      _hoveredIndex = -1;
    });
  }
}
