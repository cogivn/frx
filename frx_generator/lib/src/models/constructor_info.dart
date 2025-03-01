class ConstructorInfo {
  final String name;
  final String className;
  final String functionType;
  final String parametersPattern;
  final String callArguments;
  final List<ParameterInfo> parameters;
  final bool isPrivate;

  const ConstructorInfo({
    required this.name,
    required this.className,
    required this.functionType,
    required this.parametersPattern,
    required this.callArguments,
    required this.parameters,
    required this.isPrivate,
  });

  String get parametersType {
    if (parameters.isEmpty) return '()';
    return '(${parameters.map((p) => '${p.type} ${p.name}').join(', ')})';
  }

  String get publicClassName => isPrivate ? className.substring(1) : className;
}

class ParameterInfo {
  final String name;
  final String type;

  const ParameterInfo(this.name, this.type);
}
