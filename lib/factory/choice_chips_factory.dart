import 'package:flutter/material.dart';

import '../models/my_app/choice_chip_model.dart';

class ChoiceChipsFactory {
  List<ChoiceChipModel> create() {
    return [
      ChoiceChipModel(descricao: 'Sem glúten'),
      ChoiceChipModel(descricao: 'Sem açúcar'),
      ChoiceChipModel(descricao: 'Sem sal'),
      ChoiceChipModel(descricao: 'Sem lactose'),
    ];
  }
}
