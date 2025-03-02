import '../models/constructor_info.dart';

class MethodGenerator {
  static String generateWhen(String className, List<ConstructorInfo> constructors, bool isSealed) {
    final buffer = StringBuffer();
    buffer.writeln('  R when<R>({');
    
    // Generate required parameters
    for (var ctor in constructors) {
      if (ctor.parameters.isEmpty) {
        buffer.writeln('    required R Function() ${ctor.name},');
      } else {
        final params = ctor.parameters.map((p) => '${p.type} ${p.name}').join(', ');
        buffer.writeln('    required R Function($params) ${ctor.name},');
      }
    }
    buffer.writeln('  }) {');
    
    // Generate switch cases
    buffer.writeln('    return switch (this) {');
    for (var ctor in constructors) {
      if (ctor.parameters.isEmpty) {
        buffer.writeln('      ${ctor.className}() => ${ctor.name}(),');
      } else {
        final params = ctor.parameters.map((p) => ':final ${p.name}').join(', ');
        buffer.writeln('      ${ctor.className}($params) => ${ctor.name}(${ctor.parameters.map((p) => p.name).join(', ')}),');
      }
    }
    if (!isSealed) {
      buffer.writeln('      _ => throw UnsupportedError(\'Unsupported union case\'),');
    }
    buffer.writeln('    };');
    buffer.writeln('  }');
    return buffer.toString();
  }

  static String generateMaybeWhen(String className, List<ConstructorInfo> constructors, bool isSealed) {
    final buffer = StringBuffer();
    buffer.writeln('  R maybeWhen<R>({');
    
    // Generate parameters
    for (var ctor in constructors) {
      if (ctor.parameters.isEmpty) {
        buffer.writeln('    R Function()? ${ctor.name},');
      } else {
        final params = ctor.parameters.map((p) => '${p.type} ${p.name}').join(', ');
        buffer.writeln('    R Function($params)? ${ctor.name},');
      }
    }
    buffer.writeln('    required R Function() orElse,');
    buffer.writeln('  }) {');
    
    // Generate switch cases
    buffer.writeln('    return switch (this) {');
    for (var ctor in constructors) {
      if (ctor.parameters.isEmpty) {
        buffer.writeln('      ${ctor.className}() when ${ctor.name} != null => ${ctor.name}(),');
      } else {
        final params = ctor.parameters.map((p) => ':final ${p.name}').join(', ');
        buffer.writeln('      ${ctor.className}($params) when ${ctor.name} != null => ${ctor.name}(${ctor.parameters.map((p) => p.name).join(', ')}),');
      }
    }
    buffer.writeln('      _ => orElse(),'); // Always include default case for maybeWhen
    buffer.writeln('    };');
    buffer.writeln('  }');
    return buffer.toString();
  }

  static String generateWhenOrNull(String className, List<ConstructorInfo> constructors, bool isSealed) {
    final buffer = StringBuffer();
    
    // Create method signature
    buffer.writeln('  R? whenOrNull<R>({');
    if (constructors.isNotEmpty) {
      _writeParameters(buffer, constructors);
    }
    buffer.writeln('  }) {');
    
    // Create switch statement
    _writeSwitchCase(
      buffer,
      className,
      constructors,
      defaultCase: '      _ => null,',
      isSealed: isSealed,
    );
    
    buffer.writeln('  }');
    return buffer.toString();
  }

  static String generateMap(String className, List<ConstructorInfo> constructors, bool isSealed) {
    final publicConstructors = constructors.where((c) => !c.isPrivate).toList();
    if (publicConstructors.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('  R map<R>({');
    
    // Only generate for public constructors
    for (var ctor in publicConstructors) {
      buffer.writeln('    required R Function(${ctor.publicClassName} value) ${ctor.name},');
    }
    buffer.writeln('  }) {');
    
    buffer.writeln('    return switch (this) {');
    for (var ctor in publicConstructors) {
      buffer.writeln('      ${ctor.className}() => ${ctor.name}(this as ${ctor.publicClassName}),');
    }
    if (!isSealed) {
      buffer.writeln('      _ => throw UnsupportedError(\'Unsupported union case\'),');
    }
    buffer.writeln('    };');
    buffer.writeln('  }');  // Added missing closing brace
    return buffer.toString();
  }

  static String generateMaybeMap(String className, List<ConstructorInfo> constructors, bool isSealed) {
    final buffer = StringBuffer();
    buffer.writeln('  R maybeMap<R>({');
    
    // Only generate for public constructors
    for (var ctor in constructors.where((c) => !c.isPrivate)) {
      buffer.writeln('    R Function(${ctor.publicClassName} value)? ${ctor.name},');
    }
    buffer.writeln('    required R Function() orElse,');
    buffer.writeln('  }) {');
    
    buffer.writeln('    return switch (this) {');
    for (var ctor in constructors.where((c) => !c.isPrivate)) {
      buffer.writeln('      ${ctor.className}() => ${ctor.name}?.call(this as ${ctor.publicClassName}) ?? orElse(),');
    }
    if (!isSealed) {
      buffer.writeln('      _ => orElse(),');
    }
    buffer.writeln('    };');
    buffer.writeln('  }');
    return buffer.toString();
  }

  static String generateMapOrNull(String className, List<ConstructorInfo> constructors, bool isSealed) {
    final buffer = StringBuffer();
    buffer.writeln('  R? mapOrNull<R>({');
    
    // Only generate for public constructors
    for (var ctor in constructors.where((c) => !c.isPrivate)) {
      buffer.writeln('    R Function(${ctor.publicClassName} value)? ${ctor.name},');
    }
    buffer.writeln('  }) {');
    
    buffer.writeln('    return switch (this) {');
    for (var ctor in constructors.where((c) => !c.isPrivate)) {
      buffer.writeln('      ${ctor.className}() => ${ctor.name}?.call(this as ${ctor.publicClassName}),');
    }
    if (!isSealed) {
      buffer.writeln('      _ => null,');
    }
    buffer.writeln('    };');
    buffer.writeln('  }');
    return buffer.toString();
  }

  static void _writeParameters(
    StringBuffer buffer,
    List<ConstructorInfo> constructors,
  ) {
    for (var i = 0; i < constructors.length; i++) {
      final ctor = constructors[i];
      // Generate optional function parameter with correct return type
      buffer.write('    R Function${ctor.parametersType}? ${ctor.name}');
      if (i < constructors.length - 1) buffer.writeln(',');
    }
    if (constructors.isNotEmpty) buffer.writeln();
  }

  static void _writeSwitchCase(
    StringBuffer buffer,
    String className,
    List<ConstructorInfo> constructors,
    {required String defaultCase,
    bool isSealed = false}
  ) {
    buffer.writeln('    return switch (this) {');
    for (final ctor in constructors) {
      if (ctor.parameters.isEmpty) {
        buffer.writeln('      ${ctor.className}() => ${ctor.name}?.call(),');
      } else {
        final params = ctor.parameters.map((p) => ':final ${p.name}').join(', ');
        buffer.writeln('      ${ctor.className}($params) => ${ctor.name}?.call(${ctor.callArguments}),');
      }
    }
    if (!isSealed) {
      buffer.writeln(defaultCase);
    }
    buffer.writeln('    };');
  }
}

extension StringX on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
