import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

class ShowStarRate {
  RateMyApp rateMyApp;
  BuildContext context;

  ShowStarRate({this.context, this.rateMyApp});
  show() {
    rateMyApp.showStarRateDialog(context,
        title: 'Avalie nosso app!',
        dialogStyle: DialogStyle(
          messageAlign: TextAlign.center,
          titleStyle: TextStyle(fontSize: 22),
          messageStyle: TextStyle(
            fontSize: 18,
          ),
          messagePadding: EdgeInsets.symmetric(vertical: 12),
        ),
        barrierDismissible: false,
        message: 'Gostaria de deixar sua avaliação?',
        starRatingOptions: StarRatingOptions(initialRating: 4),
        actionsBuilder: _actionsBuilder);
  }

  List<Widget> _actionsBuilder(BuildContext context, double starRating) {
    return [_buildCancelButton(), _buildLaterButton(), _buildOkButton()];
  }

  Widget _buildCancelButton() {
    return RateMyAppNoButton(rateMyApp, text: 'NÃO, OBRIGADO');
  }

  Widget _buildOkButton() {
    return RateMyAppRateButton(rateMyApp, text: 'PUBLICAR AVALIAÇÃO');
  }

  Widget _buildLaterButton() {
    return RateMyAppLaterButton(rateMyApp, text: 'MAIS TARDE');
  }
}
