/// Represents a parameter's information
class ParameterInfo {
  final String name;
  final String type;

  const ParameterInfo(this.name, this.type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParameterInfo && 
          name == other.name && 
          type == other.type;

  @override
  int get hashCode => Object.hash(name, type);
}
