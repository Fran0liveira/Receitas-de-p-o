class TempoPreparoCheck {
  Duration duration;
  TempoPreparoCheck(this.duration);

  isNotInformed() {
    return duration == null || duration == Duration.zero;
  }

  isInformed() {
    return !isNotInformed();
  }
}
