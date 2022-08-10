// 1
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/snow_gen.dart';

// 4
Builder snowGenerator(BuilderOptions options) =>
    SharedPartBuilder([SnowGenerator()], 'snow_generator');
