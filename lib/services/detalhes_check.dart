class PorcoesCheck {
  int value;

  PorcoesCheck(this.value);

  isNotInformed() {
    return value == null || value <= 0;
  }

  isInformed() {
    return !isNotInformed();
  }

  isSingular() {
    return value == 1;
  }

  isPlural() {
    return value > 1;
  }
}
