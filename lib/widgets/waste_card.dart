import 'package:flutter/material.dart';
import '../models/waste_model.dart';

class WasteCard extends StatefulWidget {
  final WasteModel waste;
  final bool isGrid;

  const WasteCard({
    super.key,
    required this.waste,
    this.isGrid = false,
  });

  @override
  State<WasteCard> createState() => _WasteCardState();
}

class _WasteCardState extends State<WasteCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) => setState(() => _scale = 0.96);
  void _onTapUp(TapUpDetails _) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final gridLayout = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: widget.waste.color,
          child: Icon(widget.waste.icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 10),
        Text(
          widget.waste.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          '${widget.waste.points} pt/kg',
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
        ),
      ],
    );

    final listLayout = Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: widget.waste.color,
          child: Icon(widget.waste.icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.waste.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                widget.waste.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.3),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${widget.waste.points} pt/kg', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tekan tambah untuk menambahkan ${widget.waste.name}')),
                );
              },
              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              child: const Text('Pilih'),
            ),
          ],
        )
      ],
    );

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: widget.isGrid ? const EdgeInsets.symmetric(vertical: 18, horizontal: 12) : const EdgeInsets.all(12),
            child: widget.isGrid ? gridLayout : listLayout,
          ),
        ),
      ),
    );
  }
}
