class EtapaPreparo {
  String descricao;
  Duration tempo;

  EtapaPreparo({this.descricao = '', this.tempo = Duration.zero});

  static EtapaPreparo fromJson(Map<String, dynamic> map) {
    return EtapaPreparo(
        descricao: map['descricao'],
        tempo: Duration(milliseconds: map['tempo']));
  }

  Map<String, dynamic> toJson() {
    return {
      'descricao': descricao,
      'tempo': tempo.inMilliseconds,
    };
  }

  static EtapaPreparo empty() {
    return EtapaPreparo(
      descricao: '',
      tempo: Duration.zero,
    );
  }
}
