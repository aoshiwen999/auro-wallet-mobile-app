import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:auro_wallet/common/consts/enums.dart';

class ImportKeyStorePage extends StatefulWidget {
  const ImportKeyStorePage(this.store);

  static final String route = '/wallet/importkeystore';
  final AppStore store;

  @override
  _ImportKeyStorePageState createState() => _ImportKeyStorePageState(store);
}

class _ImportKeyStorePageState extends State<ImportKeyStorePage> {
  _ImportKeyStorePageState(this.store);

  final AppStore store;
  final TextEditingController _keyStoreCtrl = new TextEditingController();
  final TextEditingController _keyStorePasswordCtrl = new TextEditingController();

  @override
  void initState() {
    super.initState();

  }
  @override
  void dispose() {
    super.dispose();
    _keyStoreCtrl.dispose();
    _keyStorePasswordCtrl.dispose();
  }

  void _handleSubmit() async {
    final Map<String, String> dic = I18n.of(context).main;
    String keyStore = _keyStoreCtrl.text.trim();
    String keyStorePassword = _keyStorePasswordCtrl.text.trim();
    // EasyLoading.show(status: '');
    String? privateKey = await webApi.account.getPrivateKeyFromKeyStore(keyStore, keyStorePassword, context: context);
    // EasyLoading.dismiss();
    if (privateKey != null) {
      Map<String,dynamic> params = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;
      String accountName = params["accountName"];
      String? password = await UI.showPasswordDialog(context: context, wallet: store.wallet!.currentWallet, validate: true);
      if (password == null) {
        return;
      }
      EasyLoading.show(status: '');
      var isSuccess = await webApi.account.createWalletByPrivateKey(accountName, privateKey, password, context: context, source: WalletSource.outside);
      EasyLoading.dismiss();
      if(isSuccess) {
        UI.toast(dic['backup_success_restore']!);
        Navigator.of(context).pop();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['accountImport']!),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    InputItem(
                      label: dic['pleaseInputKeyPair']!,
                      controller: _keyStoreCtrl,
                      maxLines: 8,
                    ),
                    InputItem(
                      label: dic['pleaseInputKeyPairPwd']!,
                      controller: _keyStorePasswordCtrl,
                      isPassword: true,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                    ),
                    Flexible(
                      child: Text(dic['importAccount_2']!, style: TextStyle(fontSize: 16, color: ColorsUtil.hexColor(0x666666), height: 1.25),)
                    ),
                    Flexible(
                        child: Text(dic['importAccount_3']!, style: TextStyle(fontSize: 16, color: ColorsUtil.hexColor(0x666666), height: 1.25),)
                    ),
                  ]
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: NormalButton(
                    color: ColorsUtil.hexColor(0x6D5FFE),
                    text: I18n.of(context).main['confirm']!,
                    onPressed: _handleSubmit,
                  )
              ),
            ],
          )
        ),
      ),
    );
  }
}