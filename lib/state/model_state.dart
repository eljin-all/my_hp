enum ModelState {
  good,
  mid,
  bad,
}

class GlobalModelState {
  static final Map<String, ModelState> systemStates = {};

  static ModelState getState(String system) {
    return systemStates[system] ?? ModelState.good;
  }

  static void setState(String system, ModelState state) {
    systemStates[system] = state;
  }
}