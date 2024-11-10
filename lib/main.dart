// ignore_for_file: use_key_in_widget_constructors, avoid_print, prefer_const_constructors, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Client Form',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ClientFormScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ClientFormScreen extends StatefulWidget {
  @override
  _ClientFormScreenState createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController codeTvaController = TextEditingController();
  final TextEditingController item1QteController = TextEditingController();
  final TextEditingController item2QteController = TextEditingController();
  final TextEditingController FacQteController = TextEditingController();

  final double priceItem1 = 0.045; // Rondelle Butumée price
  final double priceItem2 = 0.095; // Rondelle Cavalier price
  late final pw.Font openSansFont;
  @override
  void initState() {
    super.initState();
    _loadFont();
  }

  Future<void> _loadFont() async {
    final fontData = await rootBundle.load('assets/OpenSans-Regular.ttf');
    openSansFont = pw.Font.ttf(fontData.buffer.asByteData());
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print('Client Name: ${clientNameController.text}');
      print('Address: ${addressController.text}');
      print('Code TVA: ${codeTvaController.text}');
      print('Rondelle Butumée Quantity: ${item1QteController.text}');
      print('Rondelle Cavalier Quantity: ${item2QteController.text}');

      _generatePdf(); // Call method to create PDF

      clientNameController.clear();
      addressController.clear();
      codeTvaController.clear();
      item1QteController.clear();
      item2QteController.clear();
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    DateTime now = DateTime.now();
    String formattedDate = "${now.day}/${now.month}/${now.year}";
    String year = '${now.year}';
    final clientName = clientNameController.text;
    final address = addressController.text;
    final codeTva = codeTvaController.text;
    final item1Quantity = int.tryParse(item1QteController.text) ?? 0;
    final item2Quantity = int.tryParse(item2QteController.text) ?? 0;
    final facnum = FacQteController.text;
    final item1Total = priceItem1 * item1Quantity;
    final item2Total = priceItem2 * item2Quantity;
    final totalAmount = item1Total + item2Total;
    Map<int, String> unites = {
      0: 'zéro',
      1: 'un',
      2: 'deux',
      3: 'trois',
      4: 'quatre',
      5: 'cinq',
      6: 'six',
      7: 'sept',
      8: 'huit',
      9: 'neuf',
      10: 'dix',
      11: 'onze',
      12: 'douze',
      13: 'treize',
      14: 'quatorze',
      15: 'quinze',
      16: 'seize',
      20: 'vingt',
      30: 'trente',
      40: 'quarante',
      50: 'cinquante',
      60: 'soixante',
      70: 'soixante-dix',
      80: 'quatre-vingts',
      90: 'quatre-vingt-dix'
    };

    String nombreEnLettres(int nombre) {
      if (nombre == 0) {
        return 'zéro';
      } else if (unites.containsKey(nombre)) {
        return unites[nombre]!;
      } else if (nombre < 20) {
        return 'dix-${unites[nombre - 10]}';
      } else if (nombre < 100) {
        int dizaine = (nombre ~/ 10) * 10;
        int reste = nombre % 10;
        return reste == 0
            ? unites[dizaine]!
            : '${unites[dizaine]}-${unites[reste]}';
      } else if (nombre < 1000) {
        int centaine = nombre ~/ 100;
        int reste = nombre % 100;
        if (reste == 0) {
          return centaine == 1 ? 'cent' : '${unites[centaine]} cent';
        } else {
          return centaine == 1
              ? 'cent ${nombreEnLettres(reste)}'
              : '${unites[centaine]} cent ${nombreEnLettres(reste)}';
        }
      } else if (nombre < 10000) {
        int mille = nombre ~/ 1000;
        int reste = nombre % 1000;
        if (reste == 0) {
          return mille == 1 ? 'mille' : '${unites[mille]} mille';
        } else {
          return mille == 1
              ? 'mille ${nombreEnLettres(reste)}'
              : '${unites[mille]} mille ${nombreEnLettres(reste)}';
        }
      } else if (nombre < 1000000) {
        int mille = nombre ~/ 1000;
        int reste = nombre % 1000;
        return reste == 0
            ? '${nombreEnLettres(mille)} mille'
            : '${nombreEnLettres(mille)} mille ${nombreEnLettres(reste)}';
      } else if (nombre < 1000000000) {
        int million = nombre ~/ 1000000;
        int reste = nombre % 1000000;
        return reste == 0
            ? '${nombreEnLettres(million)} million'
            : '${nombreEnLettres(million)} million ${nombreEnLettres(reste)}';
      } else {
        return 'Nombre trop grand';
      }
    }

    String nombreEnLettresDouble(double nombre) {
      // Séparer la partie entière et la partie décimale
      int entier = nombre.toInt();
      int decimal = ((nombre - entier) * 100)
          .toInt(); // Prendre les 2 premiers chiffres après la virgule

      String entierEnLettres = nombreEnLettres(entier);

      if (decimal == 0) {
        return entierEnLettres;
      } else {
        String decimalEnLettres;
        // Check if the decimal part is between 10 and 99, then handle it as a two-digit number
        if (decimal >= 10 && decimal < 100) {
          int dizaine = (decimal ~/ 10) * 10;
          int unite = decimal % 10;
          decimalEnLettres = unite == 0
              ? unites[dizaine]!
              : '${unites[dizaine]}-${unites[unite]}';
        } else {
          // If it's a single-digit decimal, use the previous logic
          decimalEnLettres = decimal
              .toString()
              .split('')
              .map((e) => unites[int.parse(e)]!)
              .join('-');
        }

        return '$entierEnLettres Dinars virgule $decimalEnLettres Millimes';
      }
    }

    String fullAmountInWords = nombreEnLettresDouble(
        totalAmount + (totalAmount / 100.00) + 1.00 + (totalAmount * 19 / 100));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ABDELHALIM AKERMI',
                style: pw.TextStyle(
                  font: openSansFont,
                  fontSize: 29,
                  fontWeight: pw.FontWeight.bold,
                  color:
                      PdfColors.cyan, // Set the color of the text itself here
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Accessoires de Charpente Métallique',
                  style: pw.TextStyle(
                      font: openSansFont,
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      decorationColor: PdfColors.blue)),
              pw.SizedBox(height: 10),
              pw.Text('Tel: 28 075 910 - 29 870 384',
                  style: pw.TextStyle(
                      font: openSansFont,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      decorationColor: PdfColors.blue)),
              pw.SizedBox(height: 10),
              pw.Text('MF: 1725683/B/N/C/000',
                  style: pw.TextStyle(
                      font: openSansFont,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      decorationColor: PdfColors.blue)),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Adresse: 049 Rue Ibno Jazzar 2050 Hammam Lif                                   Hammam Lif le : $formattedDate',
                  style: pw.TextStyle(
                      font: openSansFont,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      decorationColor: PdfColors.blue)),
              pw.SizedBox(height: 40),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text("Facture $facnum - $year ",
                    style: pw.TextStyle(
                        font: openSansFont,
                        fontSize: 35,
                        fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Client: $clientName',
                style: pw.TextStyle(
                    font: openSansFont,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Code TVA: $codeTva',
                    style: pw.TextStyle(
                        font: openSansFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold)),
              ),
              pw.Text('Address: $address',
                  style: pw.TextStyle(
                      font: openSansFont,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Nom Produit', 'Quantite', 'Prix Unitaire', 'Total'],
                data: [
                  [
                    'Rondelle Butumée de Diam 6 / Paquet de 200 P',
                    '$item1Quantity',
                    '\ ${priceItem1.toStringAsFixed(3)}',
                    '\ ${item1Total.toStringAsFixed(2)}'
                  ],
                  [
                    'Rondelle Cavalier de Diam 8 / Paquet de 100 P',
                    '$item2Quantity',
                    '\ ${priceItem2.toStringAsFixed(3)}',
                    '\ ${item2Total.toStringAsFixed(2)}'
                  ],
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Total HT: \ ${totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        font: openSansFont,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold)),
              ),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    'TVA(19%): \ ${(totalAmount * 19 / 100).toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        font: openSansFont,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold)),
              ),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    'FODEC 1%: \ ${(totalAmount / 100).toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        font: openSansFont,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold)),
              ),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Tmbre: \ ${(1.000).toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        font: openSansFont,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold)),
              ),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    'Total TTC: \ ${(totalAmount + (totalAmount / 100) + 1.000 + (totalAmount * 19 / 100)).toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        font: openSansFont,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'Arreté la présente Facture a la somme de : $fullAmountInWords .',
                style: pw.TextStyle(
                  font: openSansFont,
                ),
              ),
              pw.SizedBox(height: 50),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Cachet et signature',
                    style: pw.TextStyle(
                      font: openSansFont,
                      fontSize: 10,
                    )),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  void dispose() {
    clientNameController.dispose();
    addressController.dispose();
    codeTvaController.dispose();
    item1QteController.dispose();
    item2QteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue Abdelhalim'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: clientNameController,
                decoration: InputDecoration(labelText: 'Nom du client'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir le nom du client';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'adresse'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir l"adresse';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: codeTvaController,
                decoration: InputDecoration(labelText: 'Code TVA'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir le code TVA';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: item1QteController,
                decoration: InputDecoration(
                    labelText:
                        'Rondelle Butumée de Diam 6/paquet de 200P Quantite'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir la quantité pour l"article 1';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez saisir un numéro valide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: item2QteController,
                decoration: InputDecoration(
                    labelText:
                        'Rondelle Cavalier de Diam 8/paquet de 100P Quantite'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir la quantité pour l"article 2';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez saisir un numéro valide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: FacQteController,
                decoration: InputDecoration(labelText: 'Numero De la Facture'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez saisir un numéro valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Imprimer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
