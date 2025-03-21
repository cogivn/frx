import '../models/constructor_info.dart';

/// Utility class for generating pattern matching method implementations.
class MethodGenerator {
  static String generateWhen(
    String className, 
    List<ConstructorInfo> constructors, 
    bool isSealed,
    [String typeParams = '']
  ) {
    final buffer = StringBuffer();
    buffer.writeln('  R when<R>({');
    
    // Generate parameters
    for (var ctor in constructors) {
      if (ctor.parameters.isEmpty) {
        buffer.writeln('    required R Function() ${ctor.name},');
      } else {
        final params = ctor.parameters.map((p) => '${p.type} ${p.name}').join(', ');
        buffer.writeln('    required R Function($params) ${ctor.name},');
      }
    }
    buffer.writeln('  }) {');
    
    // Create switch statement without using optional call syntax
    buffer.writeln('    return switch (this) {');
    for (final ctor in constructors) {
      if (ctor.parameters.isEmpty) {
        buffer.writeln('      ${ctor.className}$typeParams() => ${ctor.name}(),');
      } else {
        final params = ctor.parameters.map((p) => ':final ${p.name}').join(', ');
        buffer.writeln('      ${ctor.className}$typeParams($params) => ${ctor.name}(${ctor.callArguments}),');
      }
    }
    if (!isSealed) {
      buffer.writeln('      _ => throw UnsupportedError(\'Unsupported union case\'),');
    }
    buffer.writeln('    };');
    
    buffer.writeln('  }');
    return buffer.toString();
  }

  // The other methods should still use the optional call syntax since their parameters are optional

  static String generateMaybeWhen(
    String className, 
    List<ConstructorInfo> constructors, 
    bool isSealed,
    [String typeParams = '']
  ) {
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

  static String generateWhenOrNull(
    String className, 
    List<ConstructorInfo> constructors, 
    bool isSealed,
    [String typeParams = '']
  ) {
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
      typeParams: typeParams,
    );
    
    buffer.writeln('  }');
    return buffer.toString();
  }

  static String generateMap(
    String className, 
    List<ConstructorInfo> constructors, 
    bool isSealed,
    [String typeParams = '']
  ) {
    final publicConstructors = constructors.where((c) => !c.isPrivate).toList();
    if (publicConstructors.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('  R map<R>({');
    
    // Only generate for public constructors
    for (var ctor in publicConstructors) {
      buffer.writeln('    required R Function(${ctor.publicClassName}$typeParams value) ${ctor.name},');
    }
    buffer.writeln('  }) {');
    
    buffer.writeln('    return switch (this) {');
    for (var ctor in publicConstructors) {
      buffer.writeln('      ${ctor.className}$typeParams() => ${ctor.name}(this as ${ctor.publicClassName}$typeParams),');
    }
    
    if (!isSealed) {
      buffer.writeln('      _ => throw UnsupportedError(\'Unsupported union case\'),');
    }
    
    buffer.writeln('    };');
    buffer.writeln('  }');
    return buffer.toString();
  }

  // Update other map methods similarly
  static String generateMaybeMap(
    String className, 
    List<ConstructorInfo> constructors, 
    bool isSealed,
    [String typeParams = '']
  ) {
    final publicConstructors = constructors.where((c) => !c.isPrivate).toList();
    if (publicConstructors.isEmpty) return '';
    
    final buffer = StringBuffer();
    buffer.writeln('  R maybeMap<R>({');
    
    // Only generate for public constructors
    for (var ctor in publicConstructors) {
      buffer.writeln('    R Function(${ctor.publicClassName}$typeParams value)? ${ctor.name},');
    }
    buffer.writeln('    required R Function() orElse,');
    buffer.writeln('  }) {');
    
    buffer.writeln('    return switch (this) {');
    for (var ctor in publicConstructors) {
      buffer.writeln('      ${ctor.className}$typeParams() => ${ctor.name}?.call(this as ${ctor.publicClassName}$typeParams) ?? orElse(),');
    }
    if (!isSealed) {
      buffer.writeln('      _ => orElse(),');
    }
    buffer.writeln('    };');
    buffer.writeln('  }');
    return buffer.toString();
  }

  static String generateMapOrNull(
    String className, 
    List<ConstructorInfo> constructors, 
    bool isSealed,
    [String typeParams = '']
  ) {
    final publicConstructors = constructors.where((c) => !c.isPrivate).toList();
    if (publicConstructors.isEmpty) return '';
    
    final buffer = StringBuffer();
    buffer.writeln('  R? mapOrNull<R>({');
    
    // Only generate for public constructors
    for (var ctor in publicConstructors) {
      buffer.writeln('    R Function(${ctor.publicClassName}$typeParams value)? ${ctor.name},');
    }
    buffer.writeln('  }) {');
    
    buffer.writeln('    return switch (this) {');
    for (var ctor in publicConstructors) {
      buffer.writeln('      ${ctor.className}$typeParams() => ${ctor.name}?.call(this as ${ctor.publicClassName}$typeParams),');
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
    bool isSealed = false,
    String typeParams = ''}
  ) {
    buffer.writeln('    return switch (this) {');
    for (final ctor in constructors) {
      if (ctor.parameters.isEmpty) {
        buffer.writeln('      ${ctor.className}$typeParams() => ${ctor.name}?.call(),');
      } else {
        final params = ctor.parameters.map((p) => ':final ${p.name}').join(', ');
        buffer.writeln('      ${ctor.className}$typeParams($params) => ${ctor.name}?.call(${ctor.callArguments}),');
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
