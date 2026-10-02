enum TurnDirection {
  straight,
  slightRight,
  turnRight,
  sharpRight,
  slightLeft,
  turnLeft,
  uTurn,
  merge,
  exitRoundabout,
  arrive,
}

/// Turn-by-turn driving instruction instruction step
class ManeuverModel {
  final String id;
  final String instruction;
  final String streetName;
  final double distanceMeters;
  final TurnDirection direction;
  final String laneIndicator; // e.g. "||^||"
  final double speedLimitKmh;

  const ManeuverModel({
    required this.id,
    required this.instruction,
    required this.streetName,
    required this.distanceMeters,
    required this.direction,
    this.laneIndicator = 'Keep Right',
    this.speedLimitKmh = 80.0,
  });
}
