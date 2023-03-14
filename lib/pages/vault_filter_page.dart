import 'package:calculator/domain/vault_filter.dart';
import 'package:calculator/pages/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class VaultFilterPage extends StatefulWidget {
  const VaultFilterPage({Key? key}) : super(key: key);

  @override
  State<VaultFilterPage> createState() => _VaultFilterPageState();
}

class _VaultFilterPageState extends State<VaultFilterPage> {
  @override
  Widget build(BuildContext context) {
    FormVaultFilter formVaultFilter = context.read<FormVaultFilter>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Vault filter'),
        ),
        drawer: const MainMenu(),
        body: ListView(
          children: <Widget>[
            createListTile(
                context,
                "Type",
                DropdownButton<VaultFilter>(
                    value: formVaultFilter.type,
                    onChanged: (VaultFilter? value) {
                      setState(() {
                        formVaultFilter.type = value!;
                      });
                    },
                    items: [
                      for (VaultFilter vaultFilter in VaultFilters())
                        DropdownMenuItem(
                          value: vaultFilter,
                          child: Text(vaultFilter.name),
                        ),
                    ])),
            if (formVaultFilter.type is ExtendedVaultFilter) const Divider(),
            if (formVaultFilter.type is ExtendedVaultFilter)
              Column(
                children: [
                  CheckboxListTile(
                      title: const Text('Pictures'),
                      value: formVaultFilter.pictures,
                      onChanged: (bool? value) {
                        setState(() {
                          formVaultFilter.pictures = value!;
                        });
                      }),
                  CheckboxListTile(
                      title: const Text('Animated pictures'),
                      value: formVaultFilter.animatedPictures,
                      onChanged: (bool? value) {
                        setState(() {
                          formVaultFilter.animatedPictures = value!;
                        });
                      }),
                  CheckboxListTile(
                      title: const Text('Movies'),
                      value: formVaultFilter.movies,
                      onChanged: (bool? value) {
                        setState(() {
                          formVaultFilter.movies = value!;
                        });
                      }),
                  if (formVaultFilter.type is ExtendedVaultFilter)
                    const Divider(),
                  if (formVaultFilter.type is ExtendedVaultFilter)
                    createListTile(
                        context,
                        "Rating",
                        Row(
                          children: [
                            for (int i = 1; i <= 5; i++)
                              IconButton(
                                  icon: Icon(
                                      i >= formVaultFilter.minNumberOfStars
                                          ? Icons.star
                                          : Icons.star_border_outlined,
                                      color: (i >=
                                              formVaultFilter.minNumberOfStars)
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Colors.black),
                                  onPressed: () {
                                    formVaultFilter.minNumberOfStars = i;
                                    setState(() {});
                                  }),
                          ],
                        )),
                ],
              ),
          ],
        ));
  }

  ListTile createListTile(
      BuildContext context, String title, Widget trailingWidget) {
    return ListTile(
      title: Row(
        children: [
          Align(alignment: Alignment.topLeft, child: Text(title)),
          const Spacer(),
          Align(
            alignment: Alignment.topRight,
            child: trailingWidget,
          )
        ],
      ),
    );
  }
}
