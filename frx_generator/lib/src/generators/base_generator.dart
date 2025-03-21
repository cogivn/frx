import '../models/constructor_info.dart';

abstract class BaseGenerator {
  const BaseGenerator();
  
  String generate(String className, List<ConstructorInfo> constructors);
  
  void writeParameters(StringBuffer buffer, List<ConstructorInfo> constructors);
  
  void writeSwitchCase(
    StringBuffer buffer,
    String className,
    List<ConstructorInfo> constructors,
  );
}
