library;

import 'package:flutter/material.dart';

/// Root [NavigatorState] for redirects that happen outside widget tree (e.g. API 401).
final appNavigatorKey = GlobalKey<NavigatorState>();
