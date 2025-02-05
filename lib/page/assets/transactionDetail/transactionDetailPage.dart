import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/customDivider.dart';
import 'package:auro_wallet/common/components/copyContainer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/common/components/browserLink.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';

class TransactionDetailPage extends StatelessWidget {
  TransactionDetailPage(this.store);

  static final String route = '/assets/tx';
  final AppStore store;
  
  Widget _buildLabel(String name) {
    return Container(
        padding: EdgeInsets.only(left: 0),
        child: Text(name,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: ColorsUtil.hexColor(0x999999),
            )));
  }

  List<Widget> _buildListView(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    final TransferData tx = ModalRoute.of(context)!.settings.arguments as TransferData;
    final success = tx.success;
    final pending = tx.isPending;

    final String symbol = COIN.coinSymbol;
    final int decimals = COIN.decimals;

    String statusIcon;
    String statusText;
    Color statusColor;
    if (pending) {
      statusIcon = 'assets/images/public/pending_tip.svg';
      statusColor = ColorsUtil.hexColor(0xFFC633);
      statusText = dic['PENDING']!;
    } else if (success == true) {
      statusIcon = 'assets/images/public/success_tip.svg';
      statusColor = ColorsUtil.hexColor(0x38d79f);
      statusText = dic['APPLIED']!;
    } else {
      statusIcon = 'assets/images/public/error_tip.svg';
      statusColor = ColorsUtil.hexColor(0xE84335);
      statusText = dic['FAILED']!;
    }

    final items = [
      TxInfoItem(
        label: dic['amount']!,
        title: '${Fmt.balance(tx.amount, decimals, minLength: 4, maxLength: decimals)} $symbol',
      ),
      TxInfoItem(
        label: dic['fromAddress']!,
        title: tx.sender,
        copyText: tx.sender,
      ),
      TxInfoItem(
        label: dic['toAddress']!,
        title: tx.receiver,
        copyText: tx.receiver,
      ),
      TxInfoItem(
        label: dic['memo2']!,
        title: tx.memo,
      ),
      TxInfoItem(
        label: dic['time']!,
        title: Fmt.dateTimeFromUTC(tx.time),
      ),
      TxInfoItem(
        label: 'Nonce',
        title: tx.nonce.toString(),
      ),
      tx.fee != null ? TxInfoItem(
        label: dic['fee']!,
        title: '${Fmt.balance(tx.fee!, decimals, maxLength: decimals)} $symbol',
      ): null,
      TxInfoItem(
        label: dic['txHash']!,
        title: tx.hash,
        copyText: tx.hash,
      ),
    ];

    var list = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: SvgPicture.asset(
                statusIcon,
                width: 71,
                height: 71,
                color: statusColor
            ),
          ),
          Text(
            statusText,
            style: Theme.of(context).textTheme.headline4!.copyWith(
                color: statusColor
            ),
          ),
          CustomDivider(
              margin: const EdgeInsets.only(top: 9)
          ),
        ],
      ),
    ];
    items.forEach((i) {
      if(i == null || i.title == null || i.title!.isEmpty) {
        return;
      }
      list.add(Container(
          padding: EdgeInsets.only(top: 11),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                _buildLabel(i.label),
                Container(height: 4),
                CopyContainer(
                  child: Text(
                      i.title!,
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                          color: ColorsUtil.hexColor(0x333333),
                          height: 1.2
                      )
                  ),
                  text: i.copyText,
                )
              ]
          )
      ));
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;

    final TransferData tx = ModalRoute.of(context)!.settings.arguments as TransferData;
    var link = 'https://hubble.figment.io/mina/chains/mainnet/transactions/${tx.hash}';
    return Scaffold(
      appBar: AppBar(
        title: Text('${I18n.of(context).main['details']!}'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 32, right: 30, left: 30),
                children: _buildListView(context),
              ),
            ),
            CustomDivider(
                margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 30)
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: BrowserLink(
                      link,
                      text: i18n['goToExplrer']!,
                    )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class TxInfoItem {
  TxInfoItem({required this.label, this.title, this.copyText});
  final String label;
  final String? title;
  final String? copyText;
}

